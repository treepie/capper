# configuration variables
_cset(:resque_workers, {})

# these cannot be overriden
set(:resque_script) { File.join(bin_path, "resque") }

after "deploy:update_code", "resque:setup"
after "deploy:restart", "resque:restart"

monit_config "resque", <<EOF, :roles => :worker
<% resque_workers.each do |name, queue| %>
check process resque_<%= name %>
with pidfile <%= pid_path %>/resque.<%= name %>.pid
<% if queue.nil? %>
start program = "<%= resque_script %> <%= name %> * start"
stop program = "<%= resque_script %> <%= name %> * stop"
<% else %>
start program = "<%= resque_script %> <%= name %> <%= queue %> start"
stop program = "<%= resque_script %> <%= name %> <%= queue %> stop"
<% end %>
group resque

<% end %>
EOF

namespace :resque do
  desc "Generate resque configuration files"
  task :setup, :roles => :worker, :except => { :no_release => true } do
    upload_template_file("resque.sh",
                         resque_script,
                         :mode => "0755")
  end

  desc "Restart resque workers"
  task :restart, :roles => :worker, :except => { :no_release => true } do
    if fetch(:monitrc, false)
      run "monit -g resque restart all"
    end
  end
end
