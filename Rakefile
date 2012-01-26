require 'rubygems'
require 'rake'
require 'yard'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), *%w(lib)))

task :default => [ :test ]

require 'rake/testtask'

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end