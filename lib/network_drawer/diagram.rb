require 'gviz'

module NetworkDrawer
  # Replesent of source file
  class Diagram
    DEFAULT_OPTIONS = {}

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
      @gv = Gviz.new(@title)
    end

    def draw
      @gv.global(rankdir: 'TB')

      create_layers
      create_nodes(@source[:nodes])
      create_connections

      @gv.save @dest_file, :svg
    end

    private

    def create_layers
      @layers.merge!(@source[:layers]) if @source[:layers]
      @layers.each_pair do |l, n|
        create_nodes(n[:nodes], l)
      end
    end

    def create_nodes(nodes, layer = nil)
      return if nodes.nil?
      nodes.reverse.each_with_index do |s, i|
        id = "#{@nodes.size + 1}".to_sym
        name = s.keys.first
        ports = s[name][:ports] ? s[name][:ports] : []
        label = build_node_label(name: name, ports: ports)
        @nodes.merge!(name =>
          { id: id, label: label, ports: ports, layer: layer })

        if layer
          @gv.subgraph "cluster_#{layer}"do
            global label: layer
            node id, label: label, shape: 'plaintext'
          end
        else
          @gv.node id, label: label, shape: 'plaintext'
        end
      end
    end

    def build_node_label(opt = {})
      if opt[:ports].empty?
        label = "<tr><td>#{opt[:name]}</td></tr>"
      else
        label = '<tr>'
        opt[:ports].each_with_index do |p, j|
          label << "<td port=\"p#{p.gsub('/', '')}\">#{p}</td>"
        end
        label << '</tr>'
        label << "<tr><td colspan=\"#{opt[:ports].size}\">#{opt[:name]}</td></tr>"
      end
      "<table>#{label}</table>"
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

        @gv.edge "#{from}_#{to}_#{seq}".gsub('/', '').to_sym
        seq += 1
      end
    end
  end
end
