require 'bundler/gem_tasks'

task default: :update

task :update do
  env = {
    'BUNDLE_GEMFILE' => nil,
    'GEM_HOME' => nil
  }

  %w(simple rank).each do |name|
    %w(png svg).each do |f|
      command =  'bundle exec bin/network_drawer '
      command << "draw examples/#{name}.yml "
      command << "-s examples/#{name}_style.yml -f #{f}"

      system(env, command)
    end
  end
end
