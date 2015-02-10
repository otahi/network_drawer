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
      @layers = []
      @gv = Gviz.new(@title)
    end

    def draw
      @gv.global(rankdir: 'TB')

      create_nodes
      create_layers
      create_connections

      @gv.save @dest_file, :svg
    end

    private

    def create_nodes
      @source[:nodes].each_with_index do |s, i|
        id = "#{i}".to_sym
        name = s[:name]
        ports = s[:ports]
        layer = s[:layer] ? s[:layer] : :default
        label = '<table>'
        @layers << layer unless @layers.include?(layer)

        if ports
          label << '<tr>'
          ports.each_with_index do |p, j|
            label << "<td port=\"p#{p.gsub('/', '')}\"> #{p} </td>"
          end
          label << '</tr>'
        end
        label << "<tr><td colspan=\"#{ports.size}\">#{name}</td></tr>"
        @nodes.merge!(name =>
          { id: id, label: label, ports: ports, layer: layer })
        label << '</table>'
      end
    end

    def create_layers
      @layers = @layers + @source[:layers] if @source[:layers]

      @layers.each do |l|
        l_nodes = @nodes.select { |_, v| v[:layer] == l }
        @gv.subgraph do
          global label: l
          l_nodes.each_value do |n|
            node n[:id], label: n[:label], shape: 'plaintext'
          end
        end
      end
    end

    def create_connections
      @source[:connections].each do |c|
        from_name, from_port  = c[:from].to_s.split(':')
        to_name, to_port = c[:to].to_s.split(':')

        from_id = @nodes[from_name][:id]
        to_id = @nodes[to_name][:id]

        from = from_port ? "#{from_id}:p#{from_port}" : from_id
        to = to_port ? "#{to_id}:p#{to_port}" : to_id

        @gv.edge "#{from}_#{to}".gsub('/', '').to_sym
      end
    end
  end
end
