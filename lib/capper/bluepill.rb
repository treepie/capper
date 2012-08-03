set(:bluepill_script) { File.join(bin_path, "bluepill") }
set(:bluepillrc) { "#{latest_release}/.bluepillrc" }

after "deploy:update_code", "bluepill:setup"
before "deploy:restart", "bluepill:start"

namespace :bluepill do
  desc "Setup bluepill config"
  task :setup do
    servers = find_servers
    configs = fetch(:bluepill_configs, {})

    upload_template(bluepillrc, :mode => "0644") do |server|
      config = configs.select do |name, config|
        roles = config[:options][:roles]
        if roles.nil?
          true
        else
          [roles].flatten.select do |r|
            self.roles[r.to_sym].include?(server)
          end.any?
        end
      end.map do |name, config|
        "# #{name}\n#{config[:body]}"
      end.join("\n\n")

      <<-EOS.dedent
        Bluepill.application("#{application}", :base_dir => "#{shared_path}") do |app|
          #{config}
        end
      EOS
    end

    upload_template_file("bluepill.sh",
                         bluepill_script,
                         :mode => "0755")
  end

  desc "Load bluepill configuration and start it"
  task :start, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path} && #{bluepill_script} load #{bluepillrc}"
  end
end
