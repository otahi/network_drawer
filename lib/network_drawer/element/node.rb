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
        label = ''

        label << port_label
        if [num_ports, num_modules].max > 0
          label << "<tr border='1'><td border='1'"
          label << " colspan=\"#{num_columns}\">#{self.name}</td></tr>"
        else
          label << "<tr border='0'><td border='0'>#{self.name}</td></tr>"
        end
        label << module_label

        "<table border='0'>#{label}</table>"
      end

      def port_label
        label = ''
        if num_ports > 0
          label << "<tr border='1'>"
          self.ports.each_with_index do |p, i|
            label << "<td border='1' port=\"p#{p.gsub('/', '')}\">#{p}</td>"
            label << row_separator(i, num_ports)
          end
          label << '</tr>'
        end
        label
      end

      def module_label
        label = ''
        if num_modules > 0
          label << "<tr border='1'>"
          self.modules.each_with_index do |p, i|
            label << "<td border='1' port=\"p#{p.gsub('/', '')}\">#{p}</td>"
            label << row_separator(i, num_modules)
          end
          label << '</tr>'
        end
        label
      end

      def row_separator(index, size)
        return '' unless self.max_column && self.max_column.to_i > 0
        if ((index + 1) % self.max_column.to_i == 0) && index + 1 < size
          "</tr><tr border='1'>"
        else
          ''
        end
      end

      def num_columns
        number = [num_ports, num_modules, 1].max
        if self.max_column && self.max_column.respond_to?(:to_i)
          number = [self.max_column, number].min
        end
        number
      end

      def num_ports
        if self.ports && self.ports.respond_to?(:size)
          self.ports.size
        else
          0
        end
      end

      def num_modules
        if self.modules && self.modules.respond_to?(:size)
          self.modules.size
        else
          0
        end
      end
    end
  end
end
