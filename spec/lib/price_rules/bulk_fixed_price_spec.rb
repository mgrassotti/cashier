require 'price_rules/bulk_fixed_price'

RSpec.describe PriceRules::BulkFixedPrice do
  describe '.initialize' do
    subject { described_class.new(data) }

    context 'with valid data' do
      let(:data) { [{ 'code' => 'SR1', 'price' => 4.5, 'threshold' => 3  }] }

      it 'initializes the object' do
        expect(subject).to be_a(PriceRules::BulkFixedPrice)
        expect(subject.data).to eq(data)
      end
    end

    context 'with invalid data' do
      let(:data) { { 'codes' => 'GR1' } }

      it 'raise an exception' do
        expect { subject }.to raise_error(PriceRules::BulkFixedPrice::InvalidData)
      end
    end
  end

  describe '#codes_count' do
    subject { described_class.new(data).codes_count(cart) }

    let(:data) { [{ 'code' => 'SR1', 'price' => 4.5, 'threshold' => 3  }] }

    context 'with a single code' do
      let(:cart) { %w[GR1] }

      it 'counts codes as expected' do
        expect(subject).to eq({ "GR1" => 1 })
      end
    end

    context 'with multiple codes' do
      let(:cart) { %w[GR1 SR1 GR1] }

      it 'counts codes as expected' do
        expect(subject).to eq({ 'GR1' => 2, 'SR1' => 1 })
      end
    end
  end

  describe '#discount_amount' do
    subject { described_class.new(data).discount_amount(cart) }

    context 'with a single code in the cart (below the threshold)' do
      let(:cart) { %w[SR1] }

      context 'with the same code in the discounts' do
        let(:data) { [{ 'code' => 'SR1', 'price' => 4.5, 'threshold' => 3  }] }

        it 'calculates as expected' do
          expect(subject).to eq(0)
        end
      end

      context 'without the same code in discount' do
        let(:data) { [{ 'code' => 'GR1', 'price' => 4.5, 'threshold' => 3  }] }

        it 'calculates as expected' do
          expect(subject).to eq(0)
        end
      end
    end

    context 'with multiple codes in the cart (above the threshold)' do
      let(:cart) { %w[GR1 SR1 SR1 SR1] }

      context 'with the same code in discount' do
        let(:data) { [{ 'code' => 'SR1', 'price' => 4.5, 'threshold' => 3  }] }

        it 'calculates as expected' do
          expect(subject).to eq(0.5 * 3)
        end
      end

      context 'without the same code in discount' do
        let(:data) { [{ 'code' => 'GR1', 'price' => 4.5, 'threshold' => 3  }] }

        it 'calculates as expected' do
          expect(subject).to eq(0)
        end
      end
    end
  end
end
