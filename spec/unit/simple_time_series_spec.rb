# frozen_string_literal: true

require 'helper'

describe SimpleTimeSeries do
  let(:time_series) { described_class.new }
  subject { time_series }
  let(:timestamp) { 1_589_052_593 }

  describe '#initialize' do
    it 'instantiates the object successfully' do
      expect(subject).to be_a SimpleTimeSeries
    end
  end

  describe '#increment' do
    subject { super().increment }

    before do
      Timecop.travel(Time.at(timestamp))
    end

    it 'stores data at the current timestamp index' do
      subject
      expect(time_series.read(timestamp)).to eq 1
    end
  end

  describe '#increment_timestamp' do
    subject { super().increment_timestamp(timestamp) }

    it 'stores data at the proper index' do
      subject
      expect(time_series.read(timestamp)).to eq 1
    end

    context 'when called repeatedly' do
      before(:each) do
        10.times { time_series.increment_timestamp(1_589_052_593) }
      end

      it 'increments the index the proper number of times' do
        expect(time_series.read(timestamp)).to eq 10
      end
    end
  end

  describe '#sum_since' do
    before do
      Timecop.travel(Time.at(timestamp))
    end

    context 'counts have been incremented' do
      before(:each) do
        (1..10).reverse_each do |i|
          3.times { time_series.increment_timestamp(timestamp - i) }
        end
      end

      it 'returns the sum of counts within the given timeframe' do
        expect(time_series.sum_since(timestamp - 10)).to eq 30
      end
    end

    context 'counts exist beyond the timeframe' do
      before(:each) do
        (1..20).reverse_each do |i|
          3.times { time_series.increment_timestamp(timestamp - i) }
        end
      end

      it 'excludes counts before the timeframe' do
        expect(time_series.sum_since(timestamp - 10)).to eq 30
      end
    end
  end
end
