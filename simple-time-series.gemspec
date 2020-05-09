# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name = 'SimpleTimeSeries'
  s.version = '0.0.1'
  s.author = 'Peter Drake'
  s.email = 'pdrake@gmail.com'
  s.description = 'Simple time series data store for counting occurrences of an event.'
  s.summary = 'See README'
  s.homepage = 'https://www.github.com/pdrakeweb/simple-time-series'
  s.license = 'GPL-2.0'

  s.add_dependency('concurrent-ruby')

  s.add_development_dependency('pry')
  s.add_development_dependency('pry-byebug')
  s.add_development_dependency('rake')
  s.add_development_dependency('rspec')
  s.add_development_dependency('rspec-benchmark')
  s.add_development_dependency('rubocop')
  s.add_development_dependency('timecop')
end
