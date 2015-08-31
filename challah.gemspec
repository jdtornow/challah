# -*- encoding: utf-8 -*-
lib = File.expand_path("../lib/", __FILE__)
$:.unshift lib unless $:.include?(lib)

require "challah/version"

Gem::Specification.new do |s|
  s.name          = "challah"
  s.version       = Challah::VERSION
  s.platform      = Gem::Platform::RUBY
  s.authors       = ["John Tornow", "Phillip Ridlen", "Nathaniel Watts"]
  s.email         = ["john@johntornow.com", "p@rdln.net", "reg@nathanielwatts.com"]
  s.homepage      = "http://github.com/jdtornow/challah"
  s.summary       = "Rails 4 authentication and sessions"
  s.description   = "A simple gem for authorization and session management in Rails."
  s.license       = "MIT"
  s.files         = Dir.glob("{app,config,db,test,lib}/**/*") + %w( README.md CHANGELOG.md )
  s.require_paths = ["lib"]

  s.add_dependency "highline", "~> 1.7.3"
  s.add_dependency "rails", "~> 4"
  s.add_dependency "rake", "~> 10.3"
  s.add_dependency "bcrypt", "~> 3.1"

  s.add_development_dependency "rspec-rails", "~> 3.1"
  s.add_development_dependency "rubocop", "~> 0.33.0"
  s.add_development_dependency "factory_girl_rails", "~> 4.5"
  s.add_development_dependency "sqlite3", "~> 1.3"

  s.required_ruby_version = Gem::Requirement.new(">= 1.9.2")
end
