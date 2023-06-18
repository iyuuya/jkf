require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task default: :spec

desc "translate documents"
task :translate do
  sh "po4a po4a.cfg"
end
