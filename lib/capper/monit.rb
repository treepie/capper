set(:monitrc) { "#{deploy_to}/.monitrc.local" }

after "deploy:update_code", "monit:setup"
before "deploy:restart", "monit:reload"

namespace :monit do
  desc "Setup monit configuration files"
  task :setup do
    configs = fetch(:monit_configs, {})
    servers = find_servers

    upload_template(monitrc, :mode => "0644") do |server|
      configs.keys.select do |name|
        roles = configs[name][:options][:roles]
        if roles.nil?
          true
        else
          [roles].flatten.select do |r|
            self.roles[r.to_sym].include?(server)
          end.any?
        end
      end.map do |name|
        "# #{name}\n#{configs[name][:body]}"
      end.join("\n\n")
    end
  end

  desc "Reload monit configuration"
  task :reload do
    run "monit reload &>/dev/null && sleep 1"
  end
end
