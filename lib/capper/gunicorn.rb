after "deploy:restart", "gunicorn:restart"
after "deploy:start", "gunicorn:restart"
after 'deploy:setup', "gunicorn:setup"

namespace :gunicorn do
  desc "Setup application in gunicorn"
    task "setup", :role => :web do
      config_file = "config/deploy/gunicorn_conf.erb"
      unless File.exists?(config_file)
        config_file = File.join(File.dirname(__FILE__), "../../generators/capistrano/gunicorn/templates/_gunicorn_conf.erb")
      end
      config = ERB.new(File.read(config_file)).result(binding)
      set :user, sudo_user
      put config, "/tmp/#{application}"
      run "#{sudo} mv /tmp/#{application} /etc/gunicorn.d/#{application}"
    end

    desc "Reload gunicorn configuration"
    task :reload, :role => :web do
      set :user, sudo_user
      run "#{sudo} /etc/init.d/gunicorn reload"
    end
    
    desc "Restart gunicorn"
    task :restart, :role => :web do
      set :user, sudo_user
      run "#{sudo} /etc/init.d/gunicorn restart"
    end
end
