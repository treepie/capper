load 'capper/ruby'

require 'bundler/capistrano'

# use bundle exec for all ruby programs
set(:ruby_exec_prefix, "bundle exec")

# do not install a global bundle if rvm has been enabled
# instead, use the gemset selected by rvm_ruby_string
set(:bundle_dir) do
  File.join([shared_path, 'bundle', fetch(:rvm_ruby_string_evaluated, nil)].compact)
end
