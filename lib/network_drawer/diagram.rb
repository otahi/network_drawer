require 'gviz'

module NetworkDrawer
  # Replesent of source file
  class Diagram
    def self.draw(source, dest_file)
      gv = Gviz.new(File.basename(dest_file, '.*'))

      nodes = {}
      layers = source['layers'] ? source['layers'] : []

      gv.global(rankdir: 'TB')
      source['nodes'].each_with_index do |s, i|
        id = "#{i}".to_sym
        name = s['name']
        ports = s['ports']
        layer = s['layer'] ? s['layer'] : :default
        label = ''
        layers << layer unless layers.include?(layer)

        if ports
          label << '{'
          ports.each_with_index do |p, j|
            label << "<p#{p.gsub('/', '')}> #{p}"
            label << '|' unless j == (ports.size - 1)
          end
          label << '}'
        end
        label << "| #{name}"
        nodes.merge!(name => { id: id, layer: layer })
        gv.node id, label: label, shape: 'record'
      end

      layers.each do |l|
        l_nodes = nodes.select { |_, v| v[:layer] == l }
        l_ids = []
        l_nodes.each_value { |v| l_ids << v[:id] }
        gv.rank :same, l_ids
      end

      source['connections'].each do |c|
        from_name, from_port  = c['from'].to_s.split(':')
        to_name, to_port = c['to'].to_s.split(':')

        from_id = nodes[from_name][:id]
        to_id = nodes[to_name][:id]

        from = from_port ? "#{from_id}:p#{from_port}" : from_id
        to = to_port ? "#{to_id}:p#{to_port}" : to_id

        gv.edge "#{from}_#{to}".gsub('/', '').to_sym
      end
      gv.save dest_file, :svg
    end
  end
end
