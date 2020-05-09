# frozen_string_literal: true

require_relative 'circular_buffer'

class SimpleTimeSeries
  # Extends the CircularBuffer class to provide an implementation that operates
  # only with Integer values.
  class IntegerCircularBuffer < CircularBuffer
    def initialize(default_value: 0, **kwargs)
      validate_integer_value(default_value)
      super
    end

    # Append a value to the end of the buffer
    #
    # @param value [Integer] - The value to append to the buffer.
    def append(value)
      validate_integer_value(value)
      super
    end

    # Insert a value into the current position in the buffer.
    #
    # @param value [Integer] - The value to insert in the buffer.
    def insert(value)
      validate_integer_value(value)
      super
    end

    # Increment the current position in the buffer by 1.
    def increment
      @buffer[@buffer_index] += 1
    end

    # Validate that the value provided is an integer.
    #
    # @raise RuntimeError
    def validate_integer_value(value)
      raise 'Invalid value: non-integer' unless value.is_a? Integer
    end
  end
end
