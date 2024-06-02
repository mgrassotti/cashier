module PriceRules
  class BulkFixedPrice
    attr_reader :data

    def initialize(data)
      @data = data
    end
  end
end
