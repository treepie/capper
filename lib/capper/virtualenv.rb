load "capper/python"

set(:python) { "#{bin_path}/python" }

before "deploy:setup", "virtualenv:setup"

namespace :virtualenv do
  desc "Create virtualenv for Python packages"
  task :setup, :except => {:no_release => true} do
    run("if [ ! -e #{bin_path}/python ]; then " +
        "virtualenv --no-site-packages #{deploy_to}; fi")
  end
end
