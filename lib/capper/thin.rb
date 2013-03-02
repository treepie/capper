# these cannot be overriden
set(:thin_script) { File.join(bin_path, "thin") }
set(:thin_service) { File.join(bin_path, "thin.service") }
set(:thin_pidfile) { File.join(pid_path, "thin.pid") }

_cset(:thin_port, 3000)

after "deploy:update_code", "thin:setup"
after "deploy:restart", "thin:restart"
after "deploy:start", "thin:start"
after "deploy:stop", "thin:stop"

namespace :thin do
  desc "Generate thin configuration files"
  task :setup, :roles => :app, :except => { :no_release => true } do
    upload_template_file("thin.sh",
                         thin_script,
                         :mode => "0755")
    upload_template_file("thin.service",
                         thin_service,
                         :mode => "0755")
    systemctl "daemon-reload"
    systemctl :enable, :thin
  end

  desc "Start thin"
  task :start, :roles => :app, :except => { :no_release => true } do
    systemctl :start, :thin
  end

  desc "Stop thin"
  task :stop, :roles => :app, :except => { :no_release => true } do
    systemctl :stop, :thin
  end

  desc "Restart thin with zero downtime"
  task :restart, :roles => :app, :except => { :no_release => true } do
    systemctl :restart, :thin
  end
end
