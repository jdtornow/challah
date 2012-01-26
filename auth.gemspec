# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
 
require 'auth/version'

Gem::Specification.new do |s|
  s.name          = "auth"
  s.version       = Auth::VERSION
  s.platform      = Gem::Platform::RUBY
  s.authors       = ["John Tornow"]
  s.email         = ["jt@ovenbits.com"]
  s.homepage      = "http://ovenbits.com"
  s.summary       = "Oven Bits Authentication Gem"
  s.description   = %Q{A simple gem for managing users, roles, permissions and session data..}
  s.files         = Dir.glob("{app,config,db,test,lib,vendor}/**/*") + %w(README.md CHANGELOG.md)
  s.require_paths = ["lib"]
  
  s.add_dependency 'rails', '>= 3.1'
  s.add_dependency 'rake', '>= 0.9.2'
  s.add_dependency 'bcrypt-ruby', '>= 0'
  
  s.required_rubygems_version = ">= 1.8.12"  
end