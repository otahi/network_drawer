require 'gviz'

module NetworkDrawer
  # Replesent of source file
  class Diagram
    def self.draw(source, dest_file)
      gv = Gviz.new

      source['servers'].each do |s|
        gv.node s['name'].to_sym, shape: 'box'
      end

      gv.save dest_file, :svg
    end
  end
end
