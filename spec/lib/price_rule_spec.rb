require 'price_rule'

RSpec.describe PriceRule do
  describe '.initialize' do
    subject { described_class.new(params) }

    context 'with valid params (2X1)' do
      let(:params) { { 'code' => '2X1', 'data' => { 'codes' => ['GR1'] } } }

      it 'returns the expected object and data' do
        expect(subject).to be_a(PriceRule)
        expect(subject.code).to eq('2X1')
        expect(subject.data).to eq({ 'codes' => ["GR1"] })
        expect(subject.rule.class).to eq(PriceRules::TwoForOne)
      end
    end

    context 'with valid params (bulk_fixed)' do
      let(:params) {
        {
          "code" => "bulk_fixed",
          "data" => [{ "code" => "SR1", "price" => 4.5, "threshold" => 3  }]
        }
      }

      it 'returns the expected object and data' do
        expect(subject).to be_a(PriceRule)
        expect(subject.code).to eq('bulk_fixed')
        expect(subject.data).to eq([{ "code" => "SR1", "price" => 4.5, "threshold" => 3  }])
        expect(subject.rule.class).to eq(PriceRules::BulkFixedPrice)
      end
    end

    context 'with valid params (bulk_percentage)' do
      let(:params) {
        {
          "code" => "bulk_percentage",
          "data" => [{ "code" => "CF1", "price" => "2/3", "threshold" => 3  }]
        }
      }

      it 'returns the expected object and data' do
        expect(subject).to be_a(PriceRule)
        expect(subject.code).to eq('bulk_percentage')
        expect(subject.data).to eq([{ "code" => "CF1", "price" => "2/3", "threshold" => 3  }])
        expect(subject.rule.class).to eq(PriceRules::BulkPercentageDiscount)
      end
    end

    context 'with invalid params' do
      let(:params) { { "code" => "GR1" } }

      it 'raise an exception' do
        expect { subject }.to raise_error(PriceRule::InvalidParams)
      end
    end
  end
end
