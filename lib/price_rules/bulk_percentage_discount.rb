module PriceRules
  class BulkPercentageDiscount
    class InvalidData < StandardError; end

    attr_reader :data, :discounts

    def initialize(data)
      valid_data!(data)

      @data = data
      @discounts = extract_discounts(data)
    end

    def extract_discounts(data)
      data.inject({}) do |mem, discount|
        # using dup avoid to change the content referenced by data too
        discount = discount.dup
        discount['price'] = fraction_to_number(discount['price'])
        mem[discount['code']] = discount
        mem
      end
    end

    def fraction_to_number(fraction)
      a, b = fraction.split('/')
      a.to_f / b.to_i
    end

    def discount_amount(cart)
      codes_count(cart).inject(0) do |mem, (code, count)|
        discount = discounts[code]
        next mem unless discount

        price = discount['price']
        threshold = discount['threshold']
        if count >= threshold
          mem += (Product.find(code).price * (1 - price)).round(2) * count
        end
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
          "Invalid data provided for Price Rule BulkPercentageDiscount: #{data}"
      end
    end

    def valid_discount?(discount)
      valid_code?(discount['code']) &&
        discount['price'].is_a?(String) && discount['price'] =~ /[0-9]\/[0-9]/ &&
          fraction_to_number(discount['price']) <= 1 &&
          discount['threshold'].is_a?(Numeric) && discount['threshold'] >= 0
    end

    def valid_code?(code)
      Product.find(code)
    end
  end
end

