require 'json'
require 'yaml'

module NetworkDrawer
  # Replesent of source file
  class Source
    def self.read(file_name)
      source = {}
      case file_type(file_name)
      when :json
        source = JSON.parse(File.read(file_name), symbolize_names: true)
      when :yaml
        source = symbolize(YAML.load(File.read(file_name)))
      else
        puts 'Incorrect file type'
        exit 1
      end
      source
    end

    def self.file_type(file_name)
      return nil unless file_name
      case file_name
      when /\.json$/
        :json
      when /\.ya?ml$/
        :yaml
      else
        nil
      end
    end
    def self.symbolize(obj)
      return obj.inject({}) do |memo, (k, v)|
        memo[k.to_sym] =  symbolize(v)
        memo
      end if obj.is_a? Hash
      return obj.inject([]) do |memo, v|
        memo << symbolize(v)
        memo
      end if obj.is_a? Array
      return obj
    end
  end
end
