# frozen_string_literal: true

require 'helper'
require 'rspec-benchmark'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe SimpleTimeSeries do
  let(:time_series) { described_class.new(thread_safe: true) }
  subject { time_series }
  let(:timestamp) { 1_589_052_593 }

  describe '#increment' do
    subject { super().increment }

    it 'increments a single value in under 100 us' do
      expect { subject }.to perform_under(100).us
    end

    it 'increments at a rate >= 1m/second' do
      expect { 100_000.times { time_series.increment } }.to perform_under(0.1).sec
    end
  end

  describe '#sum_since' do
    before do
      Timecop.thread_safe = true
      Timecop.travel(Time.at(timestamp))
    end

    context 'when thread-safety is enabled' do
      subject { time_series.sum_since(timestamp - 10) }
      let(:time_series) { described_class.new(thread_safe: true) }

      before(:each) do
        threads = []
        (0..99).each do |t|
          threads[t] = Thread.new do
            100.times { time_series.increment_timestamp(timestamp) }
            Timecop.travel(Time.at(timestamp + 1))
          end
          threads.each(&:join)
        end
      end

      it 'returns an accurate sum of counts' do
        expect(subject).to eq 10_000
      end
    end
  end

  describe '#sum_since' do
    subject { time_series.sum_since(timestamp - 299) }

    context 'a large number of values have been stored' do
      before(:each) do
        (1..300).reverse_each do |i|
          1000.times { time_series.increment_timestamp(timestamp - i) }
        end
      end

      it 'generates the report in under 1ms' do
        expect { subject }.to perform_under(1).ms
      end
    end
  end
end
