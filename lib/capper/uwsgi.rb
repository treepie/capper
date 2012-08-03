# uwsgi configuration variables
_cset(:uwsgi_worker_processes, 4)

# these cannot be overriden
set(:uwsgi_script) { File.join(bin_path, "uwsgi") }
set(:uwsgi_config) { File.join(config_path, "uwsgi.xml") }
set(:uwsgi_pidfile) { File.join(pid_path, "uwsgi.pid") }

after "deploy:update_code", "uwsgi:setup"
after "deploy:restart", "uwsgi:restart"

monit_config "uwsgi", <<EOF.dedent, :roles => :app
  check process uwsgi
  with pidfile "<%= uwsgi_pidfile %>"
  start program = "<%= uwsgi_script %> start" with timeout 60 seconds
  stop program = "<%= uwsgi_script %> stop"
EOF

bluepill_config "uwsgi", <<EOF, :roles => :app
  app.process("uwsgi") do |process|
    process.pid_file = "<%= uwsgi_pidfile %>"
    process.working_dir = "<%= current_path %>"

    process.start_command = "<%= uwsgi_script %> start"
    process.start_grace_time = 60.seconds

    process.stop_signals = [:quit, 30.seconds, :term, 5.seconds, :kill]
    process.stop_grace_time = 45.seconds
  end
EOF

namespace :uwsgi do
  desc "Generate uwsgi configuration files"
  task :setup, :roles => :app, :except => { :no_release => true } do
    upload_template_file("uwsgi.xml",
                         uwsgi_config,
                         :mode => "0644")
    upload_template_file("uwsgi.sh",
                         uwsgi_script,
                         :mode => "0755")
  end

  desc "Start uwsgi"
  task :start, :roles => :app, :except => { :no_release => true } do
    run "#{uwsgi_script} start"
  end

  desc "Stop uwsgi"
  task :stop, :roles => :app, :except => { :no_release => true } do
    run "#{uwsgi_script} stop"
  end

  desc "Reload uwsgi"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{uwsgi_script} reload"
  end
end
