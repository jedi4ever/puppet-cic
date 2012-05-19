# -*- encoding: utf-8 -*-
require File.expand_path("../lib/puppet-cic/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "puppet-cic"
  s.version     = PuppetCic::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Patrick Debois"]
  s.email       = ["patrick.debois@jedi.be"]
  s.homepage    = "http://github.com/jedi4ever/puppet-cic/"
  s.summary     = %q{Check impact of commits on puppet tree}
  s.description = %q{Check impact of commits on puppet tree}

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "puppet-cic"

  s.add_dependency "thor"

  s.add_development_dependency "bundler", ">= 1.0.0"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{ |f| f =~ /^bin\/(.*)/ ? $1 : nil }.compact
  s.require_path = 'lib'
end

