require 'rspec/core/rake_task'
require 'cucumber/rake/task'

RSpec::Core::RakeTask.new(:spec)

Cucumber::Rake::Task.new(:features) do |task|
  task.cucumber_opts = 'features --format pretty'
end


task :default => [:spec,:features]