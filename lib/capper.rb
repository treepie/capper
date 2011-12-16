require "capper/version"

# mixin various helpers
require 'capper/utils/templates'
include Capper::Utils::Templates

require 'capper/utils/multistage'
include Capper::Utils::Multistage

require 'capper/utils/monit'
include Capper::Utils::Monit

# XXX: remove capture from kernel in case activesupport has been loaded. sigh.
module ::Kernel
  begin
    remove_method :capture
  rescue NameError
  end
end

# make sure capper recipes can be found by load() too
Capistrano::Configuration.instance(true).load do
  load_paths << File.expand_path(File.dirname(__FILE__))
  load 'capper/base'
end
