before "deploy:setup", "gemrc:setup"

namespace :gemrc do
  desc "Setup global ~/.gemrc file"
  task :setup do
    put("gem: --no-ri --no-rdoc", "#{deploy_to}/.gemrc")
  end
end
