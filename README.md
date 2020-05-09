# simple-time-series
[![Build Status](https://travis-ci.com/pdrakeweb/simple-time-series.svg?branch=master)](https://travis-ci.com/pdrakeweb/simple-time-series)

## About

This is a simple gem for counting occurrences of a single event over time.  Minimal
interfaces are provided for incrementing the count of occurrences and reporting
the count from a time in the past until now.  A fixed size circular buffer is
used to store the count.

## Installation

Add this to your Gemfile and then run `bundle install`:

```
gem 'simple-time-series', ':git => 'https://github.com/pdrakeweb/simple-time-series.git'
```

## Usage

```
require 'simple_time_series'
time_series = SimpleTimeSeries.new(size: 30)

(1..5).each do
  # REAL WORK HERE
  sleep(1)
  time_series.increment
end

puts "Work completed in the past 10 seconds: " + time_series.sum_since(Time.now.to_i - 10).to_s
```
