require 'json_record'

class Product < JSONRecord
  class InvalidParams < StandardError; end

  attr_reader :code, :name, :price, :currency_symbol

  def initialize(params={})
    valid_item!(params)

    @code = params['code']
    @name = params['name']
    @price = price_without_currency(params['price'])
    @currency_symbol = currency_from_price(params['price'])
  end

  def self.json_file_name
    'products.json'
  end

  def self.all
    load_items
  end

  def self.find(code)
    all[code]
  end

  private

  def valid_item!(params)
    unless params.is_a?(Hash) && params['code'] && params['name'] &&
             valid_price?(params['price'])

      raise InvalidParams, "Invalid params provided for Product: #{params}"
    end
  end

  def valid_price?(price)
    price.is_a?(String) && price.match?(/.{1}[0-9]+\.[0-9]{2}/)
  end

  def price_without_currency(string)
    string[1..-1].to_f
  end

  def currency_from_price(string)
    string[0]
  end
end
