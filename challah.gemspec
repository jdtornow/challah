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
  s.homepage      = "https://github.com/jdtornow/challah"
  s.summary       = "Rails authentication and sessions"
  s.description   = "Authorization and session management for Rails apps"
  s.license       = "MIT"
  s.files         = Dir.glob("{app,config,db,test,lib}/**/*") + %w( README.md CHANGELOG.md VERSION )
  s.require_paths = %w( lib )

  s.metadata = {
    "bug_tracker_uri"   => "https://github.com/jdtornow/challah/issues",
    "changelog_uri"     => "https://github.com/jdtornow/challah/releases",
    "homepage_uri"      => "https://github.com/jdtornow/challah",
    "source_code_uri"   => "https://github.com/jdtornow/challah",
    "wiki_uri"          => "https://github.com/jdtornow/challah/wiki"
  }

  s.add_dependency "highline", ">= 1.7.1", "< 3"
  s.add_dependency "rails", ">= 5.2.0", "< 7"
  s.add_dependency "rake", ">= 10.3"
  s.add_dependency "bcrypt", "~> 3.1"

  s.add_development_dependency "rspec-rails", "~> 3.7"
  s.add_development_dependency "factory_bot_rails", "~> 5.1"
  s.add_development_dependency "sqlite3", "~> 1.3"
  s.add_development_dependency "rspec_junit_formatter", "~> 0.2"

  s.required_ruby_version     = ">= 2.2.2"
  s.required_rubygems_version = ">= 1.8.11"
end
