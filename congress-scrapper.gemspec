# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "congress-scrapper/version"

Gem::Specification.new do |s|
  s.name        = "congress-scrapper"
  s.version     = Congress::Scrapper::VERSION
  s.authors     = ["Luismi Cavallé", "Raimond García", "Alberto Fernández-Capel"]
  s.email       = ["voodoorai2000 at gmail"]
  s.homepage    = "http://github.com/agoraciudadana/congress-scrapper"
  s.summary     = %q{Scrapper to get proposals from Spanish Congress}
  s.description = %q{Scrapper to get proposals from Spanish Congress}

  s.rubyforge_project = "congress-scrapper"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec"
  s.add_development_dependency "webmock"
  
  s.add_runtime_dependency "progressbar"
  s.add_runtime_dependency "mechanize"
end
