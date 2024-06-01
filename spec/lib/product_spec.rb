require 'product'

RSpec.describe Product do
  let(:json) { JSON.parse File.read(path) }
  let(:path) { File.join(File.dirname(__FILE__), '../json/products.json') }

  describe '.initialize' do
    subject { described_class.new(params) }

    context 'with valid params' do
      let(:params) {
        {
          "code" => "GR1",
          "name" => "Green Tea",
          "price" => "£3.11"
        }
      }

      it 'returns the expected object and data' do
        expect(subject).to be_a(Product)
        expect(subject.code).to eq('GR1')
        expect(subject.name).to eq('Green Tea')
        expect(subject.price).to eq(3.11)
        expect(subject.currency_symbol).to eq('£')
      end
    end

    context 'with invalid params' do
      let(:params) {
        { "code" => "GR1" }
      }

      it 'raise an exception' do
        expect { subject }.to(
          raise_error(Product::InvalidParams)
            .with_message("Invalid params provided for Product: #{params}")
        )
      end
    end

    context 'with an invalid price' do
      let(:params) {
        {
          'code' =>  'GR1',
          'name' => 'Green Tea',
          'price' => '3.11£'
        }
      }

      it 'raise an exception' do
        expect { subject }.to(
          raise_error(Product::InvalidParams)
            .with_message("Invalid params provided for Product: #{params}")
        )
      end
    end
  end

  describe '.json_file_name' do
    subject { described_class.json_file_name }

    it 'returns the expected value' do
      expect(subject).to eq('products.json')
    end
  end

  describe ".all" do
    subject { described_class.all }

    context "with a valid json" do
      it "returns a Hash of products" do
        expect(subject.class).to eq(Hash)
        expect(subject.map{|k,v| v.class}.uniq).to eq([Product])
      end

      it "returns the expected data" do
        json.each do |product_data|
          product = subject[product_data['code']]

          expect(product_data['code']).to eq(product.code)
          expect(product_data['name']).to eq(product.name)
        end
      end
    end
  end

  describe ".find" do
    subject { described_class.find(code) }

    context "with an existing product code" do
      let(:code) { 'GR1' }
      let(:product_data) { {
        "code" => "GR1",
        "name" => "Green Tea",
        "price" => "£3.11"
      } }

      it "returns the product" do
        expect(subject.code).to eq(product_data['code'])
        expect(subject.name).to eq(product_data['name'])
        expect(subject.price).to eq(product_data['price'].delete('£').to_f)
        expect(subject.currency_symbol).to eq('£')
      end
    end

    context "with a non existing product code" do
      let(:code) { 'GR2' }

      it "returns nil" do
        expect(subject).to be_nil
      end
    end
  end
end
