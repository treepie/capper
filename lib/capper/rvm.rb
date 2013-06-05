load "capper/ruby"

# workaround broken capistrano detection in rvm
require "capistrano"
Kernel.const_set("Capistrano", Capistrano)

set(:rvm_ruby_string, :local)

require "rvm/capistrano"

before "deploy:setup", "rvm:install_ruby"
before "rvm:install_ruby", "rvm:install_rvm"
before "rvm:install_rvm", "rvm:install_rvmrc"
after "rvm:install_ruby", "rvm:auto_gem"

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
    wo_gemset = fetch(:rvm_ruby_string_evaluated).to_s.split('@').first
    run "touch ~/.rvm/rubies/#{wo_gemset}/lib/ruby/site_ruby/auto_gem.rb"
  end

  desc "Clear the current gemset"
  task :empty do
    run "cd #{current_release} && rvm --force gemset empty"
  end

  desc "Reinstall the current ruby version"
  task :reinstall do
    set(:rvm_install_ruby, :reinstall)
  end
end
