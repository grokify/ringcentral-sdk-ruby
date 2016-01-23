require 'rake'
require 'rake/testtask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the library.'
Rake::TestTask.new do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/test_*.rb'
  t.verbose = false
end

desc 'Generate YARD documentation.'
task :gendoc do
  # puts 'yard doc generation disabled until JRuby build native extensions for redcarpet or yard removes the dependency.'
  system 'yardoc'
  system 'yard stats --list-undoc'
end
