require 'gviz'

module NetworkDrawer
  # Replesent of source file
  class Diagram
    TOP_LAYER = :networkdrawertop
    DEFAULT_OPTIONS = {}
    ELELMENT_KEYS = [:layers, :nodes, :connections]

    def self.draw(source, dest_file, options = {})
      diagram = new(source, dest_file, options)
      diagram.draw
    end

    def initialize(source, dest_file, options = {})
      @source = source ? source : {}
      @dest_file = dest_file
      @options = DEFAULT_OPTIONS.merge(options)
      @title = @options[:title] ? @options[:title] :
        File.basename(@dest_file, '.*')
      @nodes = {}
      @layers = {}
      @connections = []
      @rankings = {}
      @style = options[:style] ? options[:style] : {}
      @gv = Gviz.new(@title)
    end

    def draw
      @layers = create_layers
      @connections = create_connections
      draw_elements

      @gv.global(layout: @options[:layout] ? @options[:layout] : :dot)
      @gv.global(newrank: true) if @rankings.size > 0
      @gv.global(@source.dup.delete_if { |k, _| ELELMENT_KEYS.include?(k) })
      @gv.save @dest_file, @options[:format]
    end

    private

    def draw_elements
      code = @layers.to_code if @layers
      @connections.each do |c|
        code << c.to_code
      end if @connections

      if @rankings.size > 0
        sorted_rankings = @rankings.sort
        rank_ids = []
        sorted_rankings.each_with_index do |r, i|
          rank_id = (@nodes.size + i)
          rank_ids << rank_id
          @gv.rank(:same, *([rank_id] + r[1]))
        end
        rank_ids.each_with_index do |r, i|
          @gv.node(r.to_s.to_sym, style: :invis)
          edge_id = "#{rank_ids[i]}_#{rank_ids[i + 1]}".to_sym
          @gv.edge(edge_id, style: :invis) if i < rank_ids.size - 1
        end
      end

      @gv.graph(&eval("proc {#{code}}"))
    end

    def create_layers(name = TOP_LAYER, source = @source)
      return nil unless source && source.is_a?(Hash)
      layer = Element::Layer.new(source, @style[:types])
      layer.name = name
      layer.layers = create_sub_layers(source)
      layer.nodes = create_nodes(source)
      layer
    end

    def create_sub_layers(source)
      return nil unless source && source[:layers]
      sub_layers = []
      source[:layers].each do |l|
        return nil unless l.is_a?(Hash)
        name = l.keys.first
        src = l[name]
        sub_layer = create_layers(name, src) if src
        sub_layers << sub_layer if sub_layer
      end
      sub_layers
    end

    def create_nodes(source)
      return nil unless source && source[:nodes]
      nodes = []
      source[:nodes].each do |n|
        return nil unless n.is_a?(Hash)
        node = Element::Node.new(n.values.first, @style[:types])
        node.name = n.keys.first
        @nodes[node.name] = { id: node.id }
        ranking = node.ranking.to_i
        unless node.ranking.nil?
          if @rankings[ranking]
            @rankings[ranking] += [node.id]
          else
            @rankings[ranking] = [node.id]
          end
        end
        nodes << node
      end
      nodes
    end

    def create_connections
      return unless @source[:connections]
      connections = []
      @source[:connections].each do |c|
        from_name, from_port  = c[:from].split(':')
        to_name, to_port = c[:to].split(':')

        from_name = from_name.to_sym
        to_name   = to_name.to_sym
        return unless node_exist?(from_name) && node_exist?(to_name)

        connection = Element::Connection.new({}, @style[:types])
        c.each_pair { |k, v| connection[k.to_sym] = v }

        from_name = @nodes[from_name][:id] if @nodes[from_name]
        to_name =   @nodes[to_name][:id] if @nodes[to_name]

        from = from_port ? "#{from_name}:p#{from_port}" : from_name
        to = to_port ? "#{to_name}:p#{to_port}" : to_name

        connection.from = from
        connection.to = to
        connections << connection
      end
      connections
    end

    def node_exist?(name)
      return false unless name
      if @nodes[name] && @nodes[name][:id]
        true
      else
        puts "No #{name} exists"
        false
      end
    end

    def node_id(name)
      return nil unless node_exist?(name)
      @nodes[name.to_sym][:id]
    end
  end
end
