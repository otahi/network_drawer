require 'network_drawer'
require 'thor'

module NetworkDrawer
  # Cli for NetworkDrawer
  class Cli < Thor
    desc 'draw SOURCE', 'draw network diagram with SOURCE file'
    option(:style, aliases: :s,
           banner: 'STYLE_FILE_IN_JSON')
    def draw(source_file)
      src = Source.read(source_file)
      style = { style: Style.read(options[:style]) }
      dest_file = source_file.gsub(File.extname(source_file), '')
      Diagram.draw(src, dest_file, style)
    end
  end
end
