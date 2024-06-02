require 'checkout'

RSpec.describe Checkout do
  let(:checkout) { Checkout.new(price_rules) }
  let(:price_rules) { [] }

  describe '#scan' do
    subject { checkout.scan(code) }

    context 'with a valid code' do
      let(:code) { 'GR1' }

      it 'adds the product to the cart' do
        expect{ subject }.to change { checkout.cart }.from([]).to([code])
      end
    end

    context 'with an invalid code' do
      let(:code) { 'GR2' }

      it 'does not add the product to the cart' do
        expect{ subject }.not_to change { checkout.cart }
      end
    end
  end

  describe "#calculated_total" do
    subject { checkout.calculated_total }

    context "without price_rules" do
      it "calculates the total as the sum of prices" do
        checkout.scan("GR1")
        checkout.scan("SR1")
        checkout.scan("CF1")

        total = 3.11 + 5.00 + 11.23
        expect(checkout.calculated_total).to eq total
      end
    end
  end

  describe "#total" do
    subject { checkout.total }
    let(:checkout) { Checkout.new(price_rules) }

    context "without price_rules" do
      let(:price_rules) { [] }

      it "returns the expected total" do
        checkout.scan("GR1")
        checkout.scan("SR1")
        checkout.scan("CF1")

        total = 3.11 + 5.00 + 11.23
        expect(checkout.total).to eq formatted_amount(total)
      end
    end

    context "with price_rules" do
      let(:price_rules) {
        [
          {
            "code" => "2X1",
            "data" => { "codes" => ["GR1"] }
          },
          {
            "code" => "bulk_fixed",
            "data" => [{ "code" => "SR1", "price" => 4.5, "threshold" => 3  }]
          },
          {
            "code" => "bulk_percentage",
            "data" => [{ "code" => "CF1", "price" => "2/3", "threshold" => 3  }]
          }
        ]
      }
      let(:test_data) {
        [
          { basket: %w[GR1 SR1 GR1 GR1 CF1], expected_total: '£22.45' },
          { basket: %w[GR1 GR1], expected_total: '£3.11' },
          { basket: %w[SR1 SR1 GR1 SR1], expected_total: '£16.61' },
          { basket: %w[GR1 CF1 SR1 CF1 CF1], expected_total: '£30.57' },
        ]
      }

      it "returns the expected totals" do
        test_data.each do |data|
          checkout = Checkout.new(price_rules)

          data[:basket].each do |code|
            checkout.scan(code)
          end

          expect(checkout.total).to eq data[:expected_total]
        end
      end
    end
  end

  def formatted_amount(amount)
    "£#{'%.2f' % amount}"
  end
end
