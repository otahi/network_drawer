require 'network_drawer'
require 'thor'

module NetworkDrawer
  # Cli for NetworkDrawer
  class Cli < Thor
    desc 'draw SOURCE', 'draw network diagram with SOURCE file'
    def draw(source_file)
      src = Source.read(source_file)
      dest_file = source_file.gsub(File.extname(source_file), '')
      Diagram.draw(src, dest_file)
    end
  end
end
