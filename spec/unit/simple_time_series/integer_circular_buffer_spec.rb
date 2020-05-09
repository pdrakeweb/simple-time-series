# frozen_string_literal: true

require 'helper'

describe SimpleTimeSeries::IntegerCircularBuffer do
  subject { described_class.new(initialization_parameters) }
  let(:default_value) { 99 }
  let(:initialization_parameters) { { default_value: default_value } }

  describe '#initialize' do
    it 'instantiates the object successfully' do
      expect(subject).to be_a SimpleTimeSeries::IntegerCircularBuffer
    end

    context 'additional arguments are passed' do
      let(:size) { 11 }
      let(:initialization_parameters) { super().merge(size: size) }

      it 'respects additional arguments' do
        expect(subject.instance_variable_get(:@size_limit)).to eq(size)
      end
    end

    context 'a non-integer default value is specified' do
      let(:default_value) { 'test' }
      it 'raises an exception' do
        expect { subject }.to raise_error(/Invalid value/)
      end
    end
  end

  describe '#append' do
    subject { super().append(value) }
    let(:value) { 1 }
    context 'a non-integer value is specified' do
      let(:value) { 'test' }
      it 'raises an exception' do
        expect { subject }.to raise_error(/Invalid value/)
      end
    end
  end

  describe '#insert' do
    subject { super().insert(value) }
    let(:value) { 1 }
    context 'a non-integer value is specified' do
      let(:value) { 'test' }
      it 'raises an exception' do
        expect { subject }.to raise_error(/Invalid value/)
      end
    end
  end

  describe '#increment' do
    subject { super().increment }
    let(:value) { 1 }

    it 'increases the value by one' do
      expect(subject).to eq default_value + 1
    end
  end
end
