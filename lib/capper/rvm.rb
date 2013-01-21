load "capper/ruby"

# workaround broken capistrano detection in rvm
require "capistrano"
Kernel.const_set("Capistrano", Capistrano)

require "rvm/capistrano"

set(:rvm_type, :user)
set(:rvm_ruby_string, File.read(".rvmrc").gsub(/^rvm( use)? --create (.*)/, '\2').strip)

_cset(:rvm_version, "1.17.10")
set(:rvm_install_type) { rvm_version }

before "deploy:setup", "rvm:install_ruby"
before "rvm:install_ruby", "rvm:install_rvm"
before "rvm:install_rvm", "rvm:install_rvmrc"
after "rvm:install_ruby", "rvm:auto_gem"
after "rvm:install_ruby", "rvm:install_rubygems"

after "deploy:create_symlink", "rvm:trust_rvmrc"

namespace :rvm do
  desc "Install a global .rvmrc"
  task :install_rvmrc, :except => {:no_release => true} do
    rvmrc = <<-EOS
export rvm_path="#{deploy_to}/.rvm"
export rvm_verbose_flag=0
export rvm_gem_options="--no-rdoc --no-ri"
    EOS

    put(rvmrc, "#{deploy_to}/.rvmrc")
  end

  desc "Ensure that Gentoos declare -x RUBYOPT=\"-rauto_gem\" is ignored"
  task :auto_gem do
    wo_gemset = rvm_ruby_string.split('@').first
    run "touch ~/.rvm/rubies/#{wo_gemset}/lib/ruby/site_ruby/auto_gem.rb"
  end

  desc "Install the specified rubygems version"
  task :install_rubygems do
    # if specified freeze rubygems version, otherwise don't touch it
    if fetch(:rvm_rubygems_version, false)
      run("rvm rubygems #{rvm_rubygems_version}")
    end
  end

  desc "Clear the current gemset"
  task :empty do
    run "cd #{current_release} && rvm --force gemset empty"
  end

  desc "Reinstall the current ruby version"
  task :reinstall do
    set(:rvm_install_ruby, :reinstall)
  end

  # prevents interactive rvm dialog
  task :trust_rvmrc, :except => {:no_release => true} do
    run "rvm rvmrc trust #{release_path} >/dev/null"
    run "rvm rvmrc trust #{current_path} >/dev/null"
  end
end
