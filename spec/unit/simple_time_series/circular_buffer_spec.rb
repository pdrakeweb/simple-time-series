# frozen_string_literal: true

require 'helper'

describe SimpleTimeSeries::CircularBuffer do
  subject { described_class.new(size: buffer_size, default_value: default_value) }
  let(:default_value) { 'default value' }
  let(:test_value) { 'test value' }
  let(:buffer_size) { 10 }

  describe '#initialize' do
    it 'sets the buffer to a single item of the default value' do
      expect(subject.read_slice(0, 0)).to eq [default_value]
    end

    it 'sets the index to zero' do
      expect(subject.index).to eq 0
    end
  end

  describe '#append' do
    let(:value) { 123 }
    let(:initial_index) { 2 }
    before(:each) do
      subject.index = initial_index
      subject.append(value)
    end

    it 'increments the index' do
      expect(subject.index).to eq initial_index + 1
    end

    context 'when called repeatedly' do
      before(:each) do
        (buffer_size * 2).times { subject.append(value) }
      end
      it 'wraps the buffer at the proper length' do
        expect(subject.internal_buffer_length).to eq(buffer_size)
      end
    end
  end

  describe '#advance' do
    let(:initial_index) { 2 }
    let(:length) { 4 }
    let(:range_start) { initial_index + 1 }
    let(:range_end) { initial_index + length }

    before(:each) do
      subject.index = initial_index
    end

    it 'increases the index' do
      subject.advance(length)
      expect(subject.index).to eq initial_index + length
    end

    it 'populates the default value in the interim range' do
      subject.advance(length)
      (range_start..range_end).each do |i|
        expect(subject.read(i)).to eq default_value
      end
    end

    context 'the buffer is already full' do
      before(:each) do
        (buffer_size - 1).times { subject.append(test_value) }
      end

      it 'populates the default value in the interim range' do
        range_start = subject.index + 1
        range_end = subject.index + length
        subject.advance(length)

        (range_start..range_end).each do |i|
          expect(subject.read(i)).to eq default_value
        end
      end
    end
  end
end
