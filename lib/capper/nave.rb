after "deploy:setup", "nave:setup"

_cset(:nave_installer_url, "https://raw.github.com/isaacs/nave/master/nave.sh")
_cset(:use_nave, true)
_cset(:nave_dir, "~/.nave")
_cset(:node_version, "stable")

namespace :nave do

  desc <<-DESC
    Install nave into nave target dir.\

    You can override the defaults by setting the variables shown below.

    set :nave_dir,      "~/.nave" # e.g. "/usr/local/nave"
  DESC

  task :setup do
    run("mkdir -p #{fetch(:nave_dir)}")
    run("curl -s -L #{nave_installer_url} > #{fetch(:nave_dir)}/nave.sh; " +
        "chmod +x #{fetch(:nave_dir)}/nave.sh",  :shell => "/bin/bash")
    install
  end

  desc <<-DESC
    Installs the specified node version. (default: stable) \

    set :node_version, "stable" # e.g. "0.8.1"
  DESC

  task :install do
    run("#{fetch(:nave_dir)}/nave.sh install #{fetch(:node_version)}")
  end
end
