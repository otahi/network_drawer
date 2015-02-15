require 'json'

module NetworkDrawer
  # Replesent of style file
  class Style
    def self.read(file_name, type = :json)
      if file_name
        JSON.parse(File.read(file_name), symbolize_names: true)
      else
        {}
      end
    end
  end
end
