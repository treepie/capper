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
    run("curl -s -L #{nave_installer_url} > #{bin_path}/nave; " +
        "chmod +x #{bin_path}/nave",  :shell => "/bin/bash")
    install
  end

  desc <<-DESC
    Installs the specified node version. (default: stable) \

    set :node_version, "stable" # e.g. "0.8.1"
  DESC

  task :install do
    run("#{bin_path}/nave install #{fetch(:node_version, 'stable')}")
  end
end
