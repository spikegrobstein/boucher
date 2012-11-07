# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "boucher/version"

Gem::Specification.new do |s|
  s.name        = "boucher"
  s.version     = Boucher::VERSION
  s.authors     = ["Spike Grobstein"]
  s.email       = ["spikegrobstein@mac.com"]
  s.homepage    = "https://github.com/spikegrobstein/boucher"
  s.summary     = %q{Bootstrap systems from generic templates for Chef infrastructure.}
  s.description = %q{Bootstrap systems from generic templates for Chef infrastructure.}

  s.rubyforge_project = "boucher"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "capistrano", '>= 2.13.5'
  s.add_dependency "term-ansicolor"
end
