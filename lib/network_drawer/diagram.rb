require 'gviz'

module NetworkDrawer
  # Replesent of source file
  class Diagram
    def self.draw(source, dest_file)
      gv = Gviz.new

      nodes = {}

      gv.global(rankdir: 'TB')
      source['servers'].each_with_index do |s, i|
        id = "#{i}".to_sym
        name = s['name']
        ports = s['ports']
        label = ''

        if ports
          label << '{'
          ports.each_with_index do |p, j|
            label << "<p#{p.gsub('/', '')}> #{p}"
            label << '|' unless j == (ports.size - 1)
          end
          label << '}'
        end
        label << "| #{name}"
        nodes.merge!(name => id)
        gv.node id, label: label, shape: 'record'
      end

      source['connections'].each do |c|
        from_name, from_port  = c['from'].to_s.split(':')
        to_name, to_port = c['to'].to_s.split(':')

        from_id = nodes[from_name]
        to_id = nodes[to_name]

        from = from_port ? "#{from_id}:p#{from_port}" : from_id
        to = to_port ? "#{to_id}:p#{to_port}" : to_id

        gv.edge "#{from}_#{to}".gsub('/', '').to_sym
      end
      gv.save dest_file, :svg
    end
  end
end
