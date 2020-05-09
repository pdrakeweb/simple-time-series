# frozen_string_literal: true

require 'bundler/setup'
require 'bundler/gem_tasks'
require 'rubocop/rake_task'
require 'rspec/core/rake_task'

desc 'Run all required tests - simply run `rake`'
task default: %w[rubocop spec]

# desc 'Run RuboCop'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.fail_on_error = true
  task.options << '--display-cop-names'
  task.options << '--display-style-guide'
end

desc 'Run spec tests.'
RSpec::Core::RakeTask.new(:spec)
