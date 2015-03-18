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
        source = YAML.load(File.read(file_name))
      else
        puts 'Incorrect file type'
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
  end
end
