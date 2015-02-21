require 'network_drawer'
require 'thor'

module NetworkDrawer
  # Cli for NetworkDrawer
  class Cli < Thor
    desc 'draw SOURCE', 'draw network diagram with SOURCE file'
    option(:style, aliases: :s,
                   banner: 'STYLE_FILE_IN_JSON')
    option(:format, aliases: :f,
                    banner: 'OUTPUT_FILE_FORMAT such as svg, png',
                    default: :svg)
    def draw(source_file)
      src = Source.read(source_file)
      op = { style: Style.read(options[:style]) }
      op.merge!(format: options[:format])
      dest_file = source_file.gsub(File.extname(source_file), '')
      Diagram.draw(src, dest_file, op)
    end
  end
end
