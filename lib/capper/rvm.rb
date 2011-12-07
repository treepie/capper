load "capper/ruby"

$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
require 'rvm/capistrano'

set(:rvm_type, :user)
set(:rvm_ruby_string, File.read(".rvmrc").gsub(/^rvm use --create (.*)/, '\1').strip)

_cset(:rvm_version, "1.9.2")
_cset(:rvm_installer_url, "https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer")

before "deploy:setup", "rvm:setup"
after "deploy:symlink", "rvm:trust_rvmrc"

namespace :rvm do
  desc "Install RVM and Ruby"
  task :setup, :except => {:no_release => true} do
    # install rvm
    run("if ! test -d #{deploy_to}/.rvm; then " +
        "curl -s #{rvm_installer_url} > #{deploy_to}/rvm-installer; " +
        "chmod +x #{deploy_to}/rvm-installer; " +
        "#{deploy_to}/rvm-installer --version #{rvm_version}; " +
        "rm -f #{deploy_to}/rvm-installer; fi",
        :shell => "/bin/bash")

    # update rvm if version differs
    run("source ~/.rvm/scripts/rvm && " +
        "if ! rvm version | grep -q 'rvm #{rvm_version}'; then" +
        "rvm get #{rvm_version}; fi",
        :shell => "/bin/bash")

    # install requested ruby version
    wo_gemset = rvm_ruby_string.gsub(/@.*/, '')

    run("echo silent > ~/.curlrc", :shell => "/bin/bash")
    run("source ~/.rvm/scripts/rvm && " +
        "if ! rvm list rubies | grep -q #{wo_gemset}; then " +
        "rvm install #{wo_gemset}; fi && " +
        "rvm use --create #{rvm_ruby_string} >/dev/null",
        :shell => "/bin/bash")
    run("rm ~/.curlrc")

    # this ensures that Gentoos declare -x RUBYOPT="-rauto_gem" is ignored.
    run "touch ~/.rvm/rubies/#{wo_gemset}/lib/ruby/site_ruby/auto_gem.rb"

    # if specified freeze rubygems version, otherwise don't touch it
    if fetch(:rvm_rubygems_version, false)
      run("rvm rubygems #{rvm_rubygems_version}")
    end
  end

  # prevents interactive rvm dialog
  task :trust_rvmrc, :except => {:no_release => true} do
    run "rvm rvmrc trust #{release_path} >/dev/null"
    run "rvm rvmrc trust #{current_path} >/dev/null"
  end
end
