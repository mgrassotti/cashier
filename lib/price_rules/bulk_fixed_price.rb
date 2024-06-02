module PriceRules
  class BulkFixedPrice
    class InvalidData < StandardError; end

    attr_reader :data, :discounts

    def initialize(data)
      valid_data!(data)

      @data = data
      @discounts = extract_discounts(data)
    end

    def extract_discounts(data)
      data.inject({}) do |mem, discount|
        mem[discount['code']] = discount
        mem
      end
    end

    def discount_amount(cart)
      codes_count(cart).inject(0) do |mem, (code, count)|
        discount = discounts[code]
        next mem unless discount

        price = discount['price']
        threshold = discount['threshold']
        mem += (Product.find(code).price - price) * count if count >= threshold
        mem
      end
    end

    def codes_count(cart)
      cart.inject({}) do |mem, code|
        mem[code] ||= 0
        mem[code] += 1
        mem
      end
    end

    private

    def valid_data!(data)
      unless data.is_a?(Array) && data.all? {|discount| valid_discount?(discount) }
        raise InvalidData,
          "Invalid data provided for Price Rule BulkFixedPrice: #{data}"
      end
    end

    def valid_discount?(discount)
      valid_code?(discount['code']) &&
        discount['price'].is_a?(Numeric) && discount['price'] >= 0 &&
        discount['threshold'].is_a?(Numeric) && discount['threshold'] >= 0
    end

    def valid_code?(code)
      Product.find(code)
    end
  end
end
