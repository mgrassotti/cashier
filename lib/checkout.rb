class Checkout
  attr_reader :price_rules, :cart

  def initialize(price_rules=[])
    @price_rules = price_rules.map{|params| PriceRule.new(params)}
    @cart = []
  end

  def scan(product_code)
    return unless Product.find(product_code)

    @cart << product_code
  end

  def calculated_total
    @total ||= cart.sum{|code| Product.find(code).price} - total_discount
  end

  def total_discount
    price_rules.sum{|price_rule| price_rule.rule.discount_amount(cart) }
  end

  def total
    "#{currency_symbol}%0.2f" % calculated_total
  end

  private

  def currency_symbol
    @currency_symbol ||= Product.find(cart.first).currency_symbol
  end
end
