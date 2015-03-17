require 'network_drawer'

module NetworkDrawer
  module Element
    # Replesent of node
    class Node < Element
      DEFAULT_STYLE = { fontname: 'Helvetica', shape: 'box' }

      def initialize(initial_values = {}, style = {})
        super
        @default_style = DEFAULT_STYLE
      end

      def to_code
        style = style(self.type).dup
        style.merge!(self.to_hash)
        style.merge!(label: build_label, tooltip: self.name, URL: self.url )
        style.merge!(ports: nil)
        "node(:\"#{self.id}\", #{style})"
      end

      private

      def build_label
        if self.ports && self.ports.size > 0
          label = "<tr border='1'>"
          self.ports.each_with_index do |p, j|
            label << "<td border='1' port=\"p#{p.gsub('/', '')}\">#{p}</td>"
          end
          label << '</tr>'
          label << "<tr border='1'><td border='1' colspan=\"#{self.ports.size}\">#{self.name}</td></tr>"
        else
          label = "<tr border='1'><td>#{self.name}</td></tr>"
        end
        "<table border='0'>#{label}</table>"
      end
    end
  end
end
