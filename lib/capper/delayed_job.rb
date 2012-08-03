# configuration variables
_cset(:delayed_job_workers, {})

# these cannot be overriden
set(:delayed_job_script) { File.join(bin_path, "delayed_job") }

after "deploy:update_code", "delayed_job:setup"
after "deploy:restart", "delayed_job:restart"

monit_config "delayed_job", <<EOF.dedent, :roles => :worker
  <% delayed_job_workers.each do |name, range| %>
  check process delayed_job_<%= name %>
  with pidfile <%= pid_path %>/delayed_job.<%= name %>.pid
  <% if range.nil? %>
  start program = "<%= delayed_job_script %> start <%= name %>"
  stop program = "<%= delayed_job_script %> stop <%= name %>"
  <% else %>
  start program = "<%= delayed_job_script %> start <%= name %> <%= range.begin %> <%= range.end %>"
  stop program = "<%= delayed_job_script %> stop <%= name %> <%= range.begin %> <%= range.end %>"
  <% end %>
  group delayed_job

  <% end %>
EOF

bluepill_config "delayed_job", <<EOF, :roles => :worker
  <% delayed_job_workers.each do |name, range| %>
  app.process("delayed_job_<%= name %>") do |process|
    process.group = "delayed_job"

    process.pid_file = "<%= pid_path %>/delayed_job.<%= name %>.pid"
    process.working_dir = "<%= current_path %>"

    <% if range.nil? %>
    process.start_command = "<%= delayed_job_script %> start <%= name %>"
    process.stop_command = "<%= delayed_job_script %> stop <%= name %>"
    <% else %>
    process.start_command = "<%= delayed_job_script %> start <%= name %> <%= range.begin %> <%= range.end %>"
    process.stop_command = "<%= delayed_job_script %> stop <%= name %> <%= range.begin %> <%= range.end %>"
    <% end %>
  end
  <% end %>
EOF

namespace :delayed_job do
  desc "Generate DelayedJob configuration files"
  task :setup, :roles => :worker, :except => { :no_release => true } do
    upload_template_file("delayed_job.sh",
                         delayed_job_script,
                         :mode => "0755")
  end

  desc "Restart DelayedJob workers"
  task :restart, :roles => :worker, :except => { :no_release => true } do
    if fetch(:monitrc, false)
      run "monit -g delayed_job restart all"
    fi
  end
end
