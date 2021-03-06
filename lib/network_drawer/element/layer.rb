require 'network_drawer'

module NetworkDrawer
  module Element
    # Replesent of layer
    class Layer < Element
      DEFAULT_STYLE = { fontname: 'Helvetica' }

      def initialize(initial_values = {}, style = {})
        super
        @default_style = DEFAULT_STYLE
      end

      def to_code
        style = style(self.type).dup
        style.merge!(self.to_hash)
        style.delete(:layers)
        style.delete(:nodes)
        style.delete(:connections)
        label = self.name unless Diagram::TOP_LAYER == self.name

        node_code = ''
        nodes.each { |n| node_code += n.to_code + "\n" } if nodes
        layer_code = ''
        layers.each { |l| layer_code += l.to_code + "\n" } if layers

        code = ''
        if Diagram::TOP_LAYER == self.name
          code = <<-EOF
            global(#{style})
            #{node_code}
            #{layer_code}
          EOF
        else
          code = <<-EOF
            subgraph "cluster_#{self.id}" do
              global label: "#{label}"
              global(#{style})
              #{node_code}
              #{layer_code}
            end
          EOF
        end
        code
      end
    end
  end
end
