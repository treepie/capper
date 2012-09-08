before "deploy:setup", "nave:setup"

_cset(:nave_installer_url, "https://raw.github.com/isaacs/nave/master/nave.sh")
_cset(:use_nave, true)

namespace :nave do

  desc <<-DESC
    Install nave into nave target dir.\

    You can override the defaults by setting the variables shown below.

    set :nave_dir,      "~/.nave" # e.g. "/usr/local/nave"
  DESC

  task :setup do
    nave_dir = fetch(:nave_dir, "~/.nave")
    run("mkdir -p #{nave_dir}")
    run("curl -s -L #{nave_installer_url} > #{nave_dir}/nave.sh; " +
           "chmod +x #{nave_dir}/nave.sh",  :shell => "/bin/bash")
    install
  end

  desc <<-DESC
    Installs the specified node version uses the latest stable as default \

    set :node_ver, "stable" # e.g. "0.8.1"
  DESC

  task :install do
    node_ver = fetch(:node_ver, 'stable')
    node_install_cmd = fetch(:nave_dir, "~/.nave") + "/nave.sh install #{node_ver}"
    run node_install_cmd
  end
end
