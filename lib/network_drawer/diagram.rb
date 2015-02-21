require 'gviz'

module NetworkDrawer
  # Replesent of source file
  class Diagram
    TOP_LAYER = :networkdrawertop
    DEFAULT_OPTIONS = {}
    DEFAULT_STYLE = { fontname: 'Helvetica' }
    DEFAULT_NODE_STYLE = { fontname: 'Helvetica', shape: 'box' }
    DEFAULT_LINE_STYLE = {}

    def self.draw(source, dest_file, options = {})
      dia = new(source, dest_file, options)
      dia.draw
    end

    def initialize(source, dest_file, options = {})
      @source = source
      @dest_file = dest_file
      @options = DEFAULT_OPTIONS.merge(options)
      @title = @options[:title] ? @options[:title] :
        File.basename(@dest_file, '.*')
      @nodes = {}
      @layers = {}
      @style = options[:style]
      @gv = Gviz.new(@title)
    end

    def draw
      @gv.global(rankdir: 'TB')
      @gv.global(DEFAULT_STYLE)
      create_nodes
      create_connections

      @gv.save @dest_file, :svg
    end

    private

    def create_nodes
      built_nodes = build_nodes(TOP_LAYER => @source)
      built_nodes[TOP_LAYER].each_value do |t|
        @gv.global DEFAULT_STYLE
        node_style = { label: t[:label] }
        node_style =
          override_style(:node, node_style, t[:type])
        @gv.node(t[:id], node_style)
      end

      built_nodes[:layers].each_pair do |n, l|
        layer_name = n
        id = "#{@layers.size + 1}".to_sym
        @layers.merge!(layer_name => id)
        l.each_value do |v|
          node_style = { label: v[:label] }
          node_style =
            override_style(:node, node_style, v[:type])
          @gv.subgraph "cluster#{id}" do
            global label: layer_name
            global DEFAULT_STYLE
            node(v[:id], node_style)
          end
        end
      end
    end

    def build_nodes(layer)
      layer_name = layer.keys.first
      nodes = layer[layer_name][:nodes]
      built_nodes = {}
      nodes.each_with_index do |s, i|
        id = "#{@nodes.size + 1}".to_sym
        name = s.keys.first
        ports = s[name][:ports] ? s[name][:ports] : []
        label = build_node_label(name: name, ports: ports)
        type = s[name][:type] ? s[name][:type].to_sym : nil
        node = { id: id, label: label, ports: ports, type: type }
        built_nodes.merge!(name => node)
        @nodes.merge!(name => node)
      end if nodes

      layers = layer[layer_name][:layers]
      built_layers = {}
      layers.each_pair do |k, v|
        built_layers.merge!(build_nodes(k => v))
      end if layers
      built_nodes = { layer_name => built_nodes, layers: built_layers }
    end

    def build_node_label(opt = {})
      if opt[:ports].empty?
        label = "<tr border='1'><td>#{opt[:name]}</td></tr>"
      else
        label = "<tr border='1'>"
        opt[:ports].each_with_index do |p, j|
          label << "<td border='1' port=\"p#{p.gsub('/', '')}\">#{p}</td>"
        end
        label << '</tr>'
        label << "<tr border='1'><td border='1' colspan=\"#{opt[:ports].size}\">#{opt[:name]}</td></tr>"
      end
      "<table border='0'>#{label}</table>"
    end

    def create_connections
      return if @source[:connections].nil?
      seq = 0
      @source[:connections].each do |c|
        from_name, from_port  = c[:from].to_s.split(':')
        to_name, to_port = c[:to].to_s.split(':')
        from_id = @nodes[from_name.to_sym][:id]
        to_id = @nodes[to_name.to_sym][:id]

        from = from_port ? "#{from_id}:p#{from_port}" : from_id
        to = to_port ? "#{to_id}:p#{to_port}" : to_id
        line_style = override_style(:line, {}, :"#{c[:type]}")

        @gv.edge "#{from}_#{to}_#{seq}".gsub('/', '').to_sym, line_style
        seq += 1
      end
    end

    def override_style(type, origin, style_type)

      default =
        case type
        when :line
          DEFAULT_LINE_STYLE
        when :node
          DEFAULT_NODE_STYLE
        else
          DEFAULT_STYLE
        end
      origin = {} unless origin
      return default.merge(origin) unless style_type
      style = @style[:types][style_type] if @style[:types]
      style ||= {}
      default.merge(origin).merge(style)
    end
  end
end
