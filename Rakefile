require 'bundler/setup'
require 'rspec/core/rake_task'
require 'byebug'

RSpec::Core::RakeTask.new('default') do |t|
  t.pattern = FileList['spec/**/*_spec.rb']
end

APP_RAKEFILE = File.expand_path("../spec/dummy/Rakefile", __FILE__)
load 'rails/tasks/engine.rake'
Bundler::GemHelper.install_tasks
