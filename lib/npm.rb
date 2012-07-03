after 'deploy:update_code', "npm:install"

namespace :npm do
  desc <<-DESC
    Install the current npm environment. \
    Note it is recommended to check in npm-shrinkwrap.json into version control\
    and to put node_module into .gitignore to manage dependencies. \
    See http://blog.nodejs.org/2012/02/27/managing-node-js-dependencies-with-shrinkwrap \
    If no npm-shrinkwrap.json is found packages are installed from package.json with no guarantee\
    about the version beeing installed
    If the npm cmd cannot be found then you can override the npm_cmd variable to specifiy \
    which one it should use.

    You can override any of these defaults by setting the variables shown below.

      set :npm_cmd,      "npm" # e.g. "/usr/local/bin/npm"
  DESC
  task :install, :roles => :app, :except => { :no_release => true } do
    npm_cmd     = fetch(:npm_cmd, "npm")
    app_path    = fetch(:latest_release)
    if app_path.to_s.empty?
      raise error_type.new("Cannot detect current release path - make sure you have deployed at least once.")
    end
    prefix  = fetch(:use_nave, false) ? "#{fetch(:nave_dir, "~/.nave")}/nave.sh use #{fetch(:node_ver, 'stable')}" :''
    run "cd #{app_path} && #{prefix} #{npm_cmd} install"
  end
end

