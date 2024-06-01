class Checkout
  attr_reader :price_rules, :cart

  def initialize(price_rules=[])
    @price_rules = price_rules
    @cart = []
  end

  def scan(product_code)
    return unless Product.find(product_code)

    @cart << product_code
  end

  def calculated_total
    @total ||= cart.sum{|code| Product.find(code).price}
  end

  def total
    "#{currency_symbol}%0.2f" % calculated_total
  end

  private

  def currency_symbol
    @currency_symbol ||= Product.find(cart.first).currency_symbol
  end
end
