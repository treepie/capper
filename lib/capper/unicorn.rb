# unicorn configuration variables
_cset(:unicorn_worker_processes, 4)
_cset(:unicorn_timeout, 30)

# these cannot be overriden
set(:unicorn_script) { File.join(bin_path, "unicorn") }
set(:unicorn_config) { File.join(config_path, "unicorn.rb") }
set(:unicorn_pidfile) { File.join(pid_path, "unicorn.pid") }

after "deploy:update_code", "unicorn:setup"
after "deploy:restart", "unicorn:restart"

monit_config "unicorn", <<EOF.dedent, :roles => :app
  check process unicorn
  with pidfile "<%= unicorn_pidfile %>"
  start program = "<%= unicorn_script %> start" with timeout 60 seconds
  stop program = "<%= unicorn_script %> stop"
EOF

bluepill_config "unicorn", <<EOF, :roles => :app
  app.process("unicorn") do |process|
    process.pid_file = "<%= unicorn_pidfile %>"
    process.working_dir = "<%= current_path %>"

    process.start_command = "<%= unicorn_script %> start"
    process.start_grace_time = 60.seconds

    process.stop_signals = [:quit, 5.seconds, :quit, 30.seconds, :term, 5.seconds, :kill]
    process.stop_grace_time = 45.seconds
  end
EOF

namespace :unicorn do
  desc "Generate unicorn configuration files"
  task :setup, :roles => :app, :except => { :no_release => true } do
    upload_template_file("unicorn.rb",
                         unicorn_config,
                         :mode => "0644")
    upload_template_file("unicorn.sh",
                         unicorn_script,
                         :mode => "0755")
  end

  desc "Start unicorn"
  task :start, :roles => :app, :except => { :no_release => true } do
    run "#{unicorn_script} start"
  end

  desc "Stop unicorn"
  task :stop, :roles => :app, :except => { :no_release => true } do
    run "#{unicorn_script} stop"
  end

  desc "Restart unicorn with zero downtime"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{unicorn_script} upgrade"
  end

  desc "Kill unicorn (this should only be used if all else fails)"
  task :kill, :roles => :app, :except => { :no_release => true } do
    run "#{unicorn_script} kill"
  end

  desc "Add a new worker to the currently running process"
  task :addworker, :roles => :app, :except => { :no_release => true } do
    run "#{unicorn_script} addworker"
  end

  desc "Remove a worker from the currently running process"
  task :delworker, :roles => :app, :except => { :no_release => true } do
    run "#{unicorn_script} delworker"
  end

  desc "Rotate all logfiles in the currently running process"
  task :logrotate, :roles => :app, :except => { :no_release => true } do
    run "#{unicorn_script} logrotate"
  end
end
