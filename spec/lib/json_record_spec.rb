require 'json_record'

RSpec.describe JSONRecord do
  let(:json) { JSON.parse File.read(path) }
  let(:items_data) {
    [
      {
        "code" =>  "GR1",
        "name" => "Green Tea",
        "price" => "£3.11"
      },
      {
        "code" =>  "SR1",
        "name" => "Strawberries",
        "price" => "£5.00"
      },
      {
        "code" =>  "CF1",
        "name" => "Coffee",
        "price" => "£11.23"
      }
    ]
  }

  describe '.load_items' do
    subject { described_class.load_items }

    context 'with a valid json file' do
      before do
        allow(JSONRecord).to(
          receive(:file_path)
            .and_return(File.join(File.dirname(__FILE__), '../json/products.json'))
        )
      end

      it 'returns the items list as a Hash' do
        items_data.each do |item_data|
          code = item_data['code']
          record = subject[code]

          expect(item_data['code']).to eq(record.data['code'])
          expect(item_data['name']).to eq(record.data['name'])
          expect(item_data['price']).to eq(record.data['price'])
        end
        expect(subject.count).to eq(3)
      end
    end

    context 'with an invalid json file' do
      before do
        allow(JSONRecord).to(
          receive(:file_path)
            .and_return(File.join(File.dirname(__FILE__), '../json/invalid_products.json'))
        )
      end

      it 'raise an exception' do
        expect { subject }.to raise_error(JSONRecord::InvalidFileFormat)
      end
    end
  end

  describe '.file_path' do
    subject { described_class.file_path }

    context 'without :json_file_name implemented (from the class itself)' do
      it 'returns an exception (it must be defined in the child class)' do
        expect { subject }.to raise_error(JSONRecord::NotImplementedError)
      end
    end

    context 'with :json_file_name implemented (from the child class)' do
      before do
        allow(JSONRecord).to(
          receive(:json_file_name).and_return('products.json')
        )
      end

      it 'returns the expected path' do
        expect(subject).to eq(JSONRecord::JSON_DIRECTORY_PATH + '/products.json')
      end
    end
  end

  describe '.json_file_name' do
    subject { described_class.json_file_name }

    it 'returns an exception (it must be defined in the child class)' do
      expect { subject }.to(
        raise_error(JSONRecord::NotImplementedError)
          .with_message("please implement :json_file_name in the target class")
      )
    end
  end

  describe '.extract_items' do
    subject { described_class.extract_items(file) }

    context 'with a valid file' do
      let(:file) { items_data }

      it 'returns a hash' do
        expect(subject).to be_a(Hash)
      end

      it 'returns the right data' do
        file.each do |item_data|
          code = item_data['code']
          record = subject[code]

          expect(item_data['code']).to eq(record.data['code'])
          expect(item_data['name']).to eq(record.data['name'])
          expect(item_data['price']).to eq(record.data['price'])
        end
        expect(subject.count).to eq(3)
      end
    end

    context 'with an invalid file format' do
      let(:file) { 'invalid' }

      it 'raise an exception' do
        expect { subject }.to raise_error(JSONRecord::InvalidFileFormat)
      end
    end
  end
end
