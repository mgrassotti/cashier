module PriceRules
  class TwoForOne
    class InvalidData < StandardError; end

    attr_reader :data

    def initialize(data)
      valid_data!(data)

      @data = data
    end

    def discount_amount(cart)
      codes_count(cart).inject(0) do |mem, (code, count)|
        # if the product is discounted
        if data['codes'].include?(code)
          mem += (count / 2) * Product.find(code).price
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
      unless data['codes'].is_a?(Array) &&
              data['codes'].all?{|code| valid_code?(code) }

        raise InvalidData, "Invalid data provided for Price Rule 2X1: #{data}"
      end
    end

    def valid_code?(code)
      Product.find(code)
    end
  end
end
