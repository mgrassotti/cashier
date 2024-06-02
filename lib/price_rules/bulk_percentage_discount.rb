module PriceRules
  class BulkPercentageDiscount
    attr_reader :data

    def initialize(data)
      @data = data
    end
  end
end
