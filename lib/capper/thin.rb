# these cannot be overriden
set(:thin_script) { File.join(bin_path, "thin") }
set(:thin_pidfile) { File.join(pid_path, "thin.pid") }

_cset(:thin_port, 3000)

after "deploy:update_code", "thin:setup"
after "deploy:restart", "thin:restart"

monit_config "thin", <<EOF.dedent, :roles => :app
  check process thin
  with pidfile "<%= thin_pidfile %>"
  start program = "<%= thin_script %> start" with timeout 60 seconds
  stop program = "<%= thin_script %> stop"
EOF

bluepill_config "thin", <<EOF, :roles => :app
  app.process("thin") do |process|
    process.pid_file = "<%= thin_pidfile %>"
    process.working_dir = "<%= current_path %>"

    process.start_command = "<%= thin_script %> start"
    process.start_grace_time = 60.seconds

    process.stop_signals = [:quit, 5.seconds, :quit, 30.seconds, :term, 5.seconds, :kill]
    process.stop_grace_time = 45.seconds
  end
EOF

namespace :thin do
  desc "Generate thin configuration files"
  task :setup, :roles => :app, :except => { :no_release => true } do
    upload_template_file("thin.sh",
                         thin_script,
                         :mode => "0755")
  end

  desc "Start thin"
  task :start, :roles => :app, :except => { :no_release => true } do
    run "#{thin_script} start"
  end

  desc "Stop thin"
  task :stop, :roles => :app, :except => { :no_release => true } do
    run "#{thin_script} stop"
  end

  desc "Restart thin with zero downtime"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{thin_script} kill"
    run "#{thin_script} start"
  end

  desc "Kill thin (this should only be used if all else fails)"
  task :kill, :roles => :app, :except => { :no_release => true } do
    run "#{thin_script} kill"
  end
end
