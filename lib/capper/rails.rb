load 'capper/rvm'
load 'capper/bundler'

_cset(:rails_env, "production")

after "deploy:update_code", "rails:setup"

namespace :rails do
  desc "Generate rails configuration and helpers"
  task :setup, :roles => :app, :except => { :no_release => true } do
    upload_template_file("rails.console.sh",
                         File.join(bin_path, "con"),
                         :mode => "0755")
  end
end
