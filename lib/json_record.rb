require 'json'

class JSONRecord
  class NotImplementedError < StandardError; end
  class InvalidFileFormat < StandardError
    def message
      'Invalid items file, please provide an array of hashes'
    end
  end

  JSON_DIRECTORY_PATH = File.join(File.dirname(__FILE__), '../json')

  attr_reader :data

  def initialize(params={})
    @data = params
  end

  def self.load_items
    file = JSON.parse File.read(file_path)

    extract_items file
  end

  def self.file_path
    File.join JSON_DIRECTORY_PATH, json_file_name
  end

  def self.json_file_name
    raise NotImplementedError, "please implement :#{__method__} in the target class"
  end

  # Extract the items and stores them in an hash with format:
  # { 'code' => item }
  def self.extract_items(file)
    valid_file_format! file

    file.inject({}) do |mem, item|
      code = item['code']
      new_item = self.new item

      mem[code] = new_item

      mem
    end
  end

  def self.valid_file_format!(file)
    unless file.is_a?(Array) && file.all?{|p| p.is_a?(Hash)}
      raise InvalidFileFormat
    end
  end
end
