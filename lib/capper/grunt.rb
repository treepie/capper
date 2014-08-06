after 'deploy:update_code', "grunt:build"
after 'deploy:update_code', "grunt:generate_index"

namespace :grunt do
  desc <<-DESC
    Run the grunt build task. \
    
    If the grunt cmd cannot be found then you can override the grunt_cmd variable to specifiy \
    which one it should use.

    You can override any of these defaults by setting the variables shown below.

      set :grunt_cmd,      "grunt" # e.g. "/usr/local/bin/grunt"
  DESC
  task :build, :roles => :app, :except => { :no_release => true } do
    node_env        = fetch(:build_node_env,'development')
    prefix = fetch(:use_nave, false) ? "#{fetch(:nave_dir)}/nave.sh use #{fetch(:node_version, 'stable')}" : ''
    run("cd #{latest_release} && NODE_ENV=#{node_env} #{prefix} #{fetch(:grunt_cmd, "node ./node_modules/.bin/grunt")} build")
  end
  desc <<-DESC
    Run the grunt generate task. \
    
    If the grunt cmd cannot be found then you can override the grunt_cmd variable to specifiy \
    which one it should use.

    You can override any of these defaults by setting the variables shown below.

      set :grunt_cmd,      "grunt" # e.g. "/usr/local/bin/grunt"
  DESC
  task :generate_index, :roles => :app, :except => { :no_release => true } do
    node_env        = fetch(:node_env,'production')
    prefix = fetch(:use_nave, false) ? "#{fetch(:nave_dir)}/nave.sh use #{fetch(:node_version, 'stable')}" : ''
    run("cd #{latest_release} && NODE_ENV=#{node_env} #{prefix} #{fetch(:grunt_cmd, "node ./node_modules/.bin/grunt")} execute:generate_index")
  end
end

