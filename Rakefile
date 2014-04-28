require 'rspec/core/rake_task'

desc 'Run the unit tests for the Stedman codebase'
RSpec::Core::RakeTask.new(:test) do |t|
  t.rspec_opts = '-fd -c'
end

task :default => :test

