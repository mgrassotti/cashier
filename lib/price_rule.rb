require 'json_record'
Dir[File.join(File.dirname(__FILE__), 'price_rules/*.rb')].each {|file| require file }

class PriceRule
  class InvalidParams < StandardError; end

  RULES_CLASSES = {
    '2X1' => PriceRules::TwoForOne,
    'bulk_fixed' => PriceRules::BulkFixedPrice,
    'bulk_percentage' => PriceRules::BulkPercentageDiscount
  }

  attr_reader :code, :data, :rule

  # Example of valid params:
  # [
  #   { "code": "2X1",  "data": { "codes": ["GR1"] } },
  #   { "code": "bulk_fixed", "data": [{ "code": "SR1", "price": 4.5, "threshold": 3  }] },
  #   { "code": "bulk_percentage", "data": [{ "code": "CF1", "price": "2/3", "threshold": 3  }] }
  # ]
  def initialize(params={})
    valid_item!(params)

    @code = params['code']
    @data = params['data']
    @rule = RULES_CLASSES[@code].new(@data)
  end

  private

  def valid_item!(params)
    unless params.is_a?(Hash) && valid_code?(params['code'])

      raise InvalidParams, "Invalid params provided for PriceRule: #{params}."
    end
  end

  def valid_code?(code)
    valid_codes.include?(code)
  end

  def valid_codes
    RULES_CLASSES.keys
  end
end
