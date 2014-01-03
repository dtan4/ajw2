require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "ci/reporter/rake/rspec"
require "yard"

RSpec::Core::RakeTask.new(:spec)
YARD::Rake::YardocTask.new(:yard)

task :default => :spec
