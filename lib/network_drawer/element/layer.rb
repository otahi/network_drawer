require 'network_drawer'

module NetworkDrawer
  module Element
    # Replesent of layer
    class Layer < Element
      def to_code
        node_code = ''
        nodes.each { |n| node_code += n.to_code + "\n" } if nodes
        layer_code = ''
        layers.each { |l| layer_code += l.to_code + "\n" } if layers
        <<-EOF
        #{node_code}
        subgraph do
          #{layer_code}
        end
        EOF
      end
    end
  end
end
