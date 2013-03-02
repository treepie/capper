# uwsgi configuration variables
_cset(:uwsgi_worker_processes, 4)

# these cannot be overriden
set(:uwsgi_script) { File.join(bin_path, "uwsgi") }
set(:uwsgi_service) { File.join(units_path, "uwsgi.service") }
set(:uwsgi_config) { File.join(config_path, "uwsgi.xml") }
set(:uwsgi_pidfile) { File.join(pid_path, "uwsgi.pid") }

after "deploy:update_code", "uwsgi:setup"
after "deploy:restart", "uwsgi:reload"
after "deploy:start", "uwsgi:start"
after "deploy:stop", "uwsgi:stop"

namespace :uwsgi do
  desc "Generate uwsgi configuration files"
  task :setup, :roles => :app, :except => { :no_release => true } do
    upload_template_file("uwsgi.xml",
                         uwsgi_config,
                         :mode => "0644")
    upload_template_file("uwsgi.sh",
                         uwsgi_script,
                         :mode => "0755")
    upload_template_file("uwsgi.service",
                         uwsgi_service,
                         :mode => "0755")
    systemctl "daemon-reload"
    systemctl :enable, :uwsgi
  end

  desc "Start uwsgi"
  task :start, :roles => :app, :except => { :no_release => true } do
    systemctl :start, :uwsgi
  end

  desc "Stop uwsgi"
  task :stop, :roles => :app, :except => { :no_release => true } do
    systemctl :stop, :uwsgi
  end

  desc "Reload uwsgi"
  task :restart, :roles => :app, :except => { :no_release => true } do
    systemctl :restart, :uwsgi
  end

  desc "Reload uwsgi"
  task :reload, :roles => :app, :except => { :no_release => true } do
    run "#{uwsgi_script} reload"
  end
end
