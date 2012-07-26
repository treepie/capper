load 'capper/ruby'

require 'bundler/capistrano'

# use bundle exec for all ruby programs
set(:ruby_exec_prefix, "bundle exec")

# do not install a global bundle if rvm has been enabled
# instead, use the gemset selected by rvm_ruby_string
set(:bundle_dir) do
  begin
    File.join(shared_path, 'bundle', rvm_ruby_string)
  rescue NoMethodError, NameError
    File.join(shared_path, 'bundle')
  end
end

# freeze bundler version
_cset(:bundler_version, "1.1.4")

before "bundle:install", "bundle:setup"

namespace :bundle do
  desc "Setup bundler"
  task :setup, :except => {:no_release => true} do
    run "if ! gem query -i -n ^bundler$ -v #{bundler_version} >/dev/null; then " +
        "gem install bundler -v #{bundler_version}; " +
        "fi"
    run "mkdir -p #{bundle_dir}"
  end
end
