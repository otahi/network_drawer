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
        label = '<table>'
        layers << layer unless layers.include?(layer)

        if ports
          label << '<tr>'
          ports.each_with_index do |p, j|
            label << "<td port=\"p#{p.gsub('/', '')}\"> #{p} </td>"
          end
          label << '</tr>'
        end
        label << "<tr><td colspan=\"#{ports.size}\">#{name}</td></tr>"
        nodes.merge!(name => { id: id, label: label, ports: ports, layer: layer })
        label << '</table>'
      end

      layers.each do |l|
        l_nodes = nodes.select { |_, v| v[:layer] == l }
        gv.subgraph do
          global label: l
          l_nodes.each_value do |n|
            node n[:id], label: n[:label], shape: 'plaintext'
          end
        end
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
