# mixin various helpers
require 'capper/utils/templates'
include Capper::Utils::Templates

require 'capper/utils/multistage'
include Capper::Utils::Multistage

require 'capper/utils/monit'
include Capper::Utils::Monit

# make sure capper recipes can be found by load() too
Capistrano::Configuration.instance(true).load do
  load_paths << File.expand_path(File.dirname(__FILE__))
  load 'deploy'
  load 'capper/base'
end
