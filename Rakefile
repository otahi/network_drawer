require 'bundler/gem_tasks'

task default: :update

task :update do
  %w(png svg).each do |f|
    system('network_drawer', 'draw', 'example/simple.json',
           '-s', 'examples/simple_style.json',
           '-f', f)
  end
end
