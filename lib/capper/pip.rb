after "deploy:finalize_update", "pip:install"

namespace :pip do
  task :install do
    run("pip install -E #{deploy_to} -r #{latest_release}/requirements.txt")
  end
end
