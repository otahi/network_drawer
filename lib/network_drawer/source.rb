require 'json'

module NetworkDrawer
  # Replesent of source file
  class Source
    def self.read(file_name, type = :json)
      JSON.parse(File.read(file_name), symbolize_names: true)
    end
  end
end
