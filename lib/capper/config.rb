_cset(:config_repo, nil)

after "deploy:setup", "config:setup"
after "deploy:update_code", "config:deploy"

namespace :config do
  desc "Setup configuration repository if any"
  task :setup, :roles => :app, :except => { :no_release => true } do
    unless config_repo.nil?
      run "rm -rf #{config_path} && git clone -q #{config_repo} #{config_path}"
    end
  end

  desc "Deploy config files from shared/config to current release"
  task :deploy, :roles => :app, :except => { :no_release => true } do
    unless config_repo.nil?
      run "cd #{config_path} && git pull -q"
    end

    fetch(:config_files, []).each do |f|
      run "cp #{config_path}/#{f} #{release_path}/config/"
    end
  end
end
