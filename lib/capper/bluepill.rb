set(:bluepill_script) { File.join(bin_path, "bluepill") }
set(:bluepill_config) { "#{release_path}/bluepill.rb" }

after "deploy:update_code", "bluepill:setup"
before "deploy:restart", "bluepill:start"

namespace :bluepill do
  desc "Setup bluepill config"
  task :setup do
    upload_template_file("bluepill.rb",
                         bluepill_config,
                         :mode => "0644")
    upload_template_file("bluepill.sh",
                         bluepill_script,
                         :mode => "0755")
  end

  desc "Load bluepill configuration and start it"
  task :start, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path} && #{bluepill_script} load bluepill.rb"
  end
end
