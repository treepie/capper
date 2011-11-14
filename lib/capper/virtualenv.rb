load "capper/python"

set(:python) { "#{bin_path}/python" }

before "deploy:setup", "virtualenv:setup"

after "deploy:finalize_update", "pip:install"

namespace :virtualenv do
  desc "Create virtualenv for Python packages"
  task :setup, :except => {:no_release => true} do
    run("if [ ! -e #{bin_path}/python ]; then " +
        "virtualenv -q --no-site-packages #{deploy_to}; fi")
  end
end

namespace :pip do
  task :install do
    run("#{bin_path}/pip install -q -E #{deploy_to} -r #{latest_release}/requirements.txt")
  end
end
