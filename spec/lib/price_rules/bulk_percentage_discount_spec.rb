require 'price_rules/bulk_percentage_discount'

RSpec.describe PriceRules::BulkPercentageDiscount do
  describe '.initialize' do
    subject { described_class.new(data) }

    context 'with valid data' do
      let(:data) { [{ 'code' => 'CF1', 'price' => '2/3', 'threshold' => 3  }] }

      it 'initializes the object' do
        expect(subject).to be_a(PriceRules::BulkPercentageDiscount)
        expect(subject.data).to eq(data)
        discounts = subject.discounts
        code = data.first['code']
        expect(discounts[code]['code']).to eq(code)
        expect(discounts[code]['price']).to eq(2.to_f / 3.to_i)
        expect(discounts[code]['threshold']).to eq(data.first['threshold'])
      end
    end

    context 'with invalid data' do
      let(:data) { [{ 'code' => 'CF1', 'price' => 4.55, 'threshold' => 3  }] }

      it 'raise an exception' do
        expect { subject }.to raise_error(PriceRules::BulkPercentageDiscount::InvalidData)
      end
    end
  end

  describe '#codes_count' do
    subject { described_class.new(data).codes_count(cart) }

    let(:data) { [{ 'code' => 'CF1', 'price' => '2/3', 'threshold' => 3  }] }

    context 'with a single code' do
      let(:cart) { %w[GR1] }

      it 'counts codes as expected' do
        expect(subject).to eq({ "GR1" => 1 })
      end
    end

    context 'with multiple codes' do
      let(:cart) { %w[GR1 CF1 GR1] }

      it 'counts codes as expected' do
        expect(subject).to eq({ 'GR1' => 2, 'CF1' => 1 })
      end
    end
  end

  describe '#discount_amount' do
    subject { described_class.new(data).discount_amount(cart) }

    context 'with a single code in the cart (below the threshold)' do
      let(:cart) { %w[CF1] }

      context 'with the same code in the discounts' do
        let(:data) { [{ 'code' => 'CF1', 'price' => '2/3', 'threshold' => 3  }] }

        it 'calculates as expected' do
          expect(subject).to eq(0)
        end
      end

      context 'without the same code in discount' do
        let(:data) { [{ 'code' => 'GR1', 'price' => '2/3', 'threshold' => 3  }] }

        it 'calculates as expected' do
          expect(subject).to eq(0)
        end
      end
    end

    context 'with multiple codes in the cart (above the threshold)' do
      let(:cart) { %w[GR1 CF1 CF1 CF1] }

      context 'with the same code in discount' do
        let(:data) { [{ 'code' => 'CF1', 'price' => '2/3', 'threshold' => 3  }] }

        it 'calculates as expected' do
          expect(subject).to eq((Product.find('CF1').price * (1 - 2.to_f / 3)).round(2) * 3)
        end
      end

      context 'without the same code in discount' do
        let(:data) { [{ 'code' => 'GR1', 'price' => '2/3', 'threshold' => 3  }] }

        it 'calculates as expected' do
          expect(subject).to eq(0)
        end
      end
    end
  end
end
