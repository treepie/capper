# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "capper/version"

Gem::Specification.new do |s|
  s.name = "capper"
  s.version = Capper::VERSION
  s.authors = ["Benedikt Böhm"]
  s.email = ["bb@xnull.de"]
  s.homepage = "http://github.com/zenops/capper"
  s.summary = %q{Capper is a collection of opinionated Capistrano recipes}
  s.description = %q{Capper is a collection of opinionated Capistrano recipes}

  s.files            = `git ls-files`.split("\n")
  s.test_files       = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables      = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths    = ["lib"]

  s.add_dependency "erubis"
  s.add_dependency "capistrano", "~> 2.12.0"
  s.add_dependency "capistrano_colors", "~> 0.5.5"
  s.add_dependency "rvm-capistrano", "~> 1.2.3"
end
