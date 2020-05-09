# frozen_string_literal: true

require 'concurrent-ruby'

class SimpleTimeSeries
  # Provides an implementation of a simple circular buffer.  This buffer is of a
  # fixed size and stores values in the current index only.  Previous indexes can
  # be read but not modified.
  #
  # @todo allow previous indexes to be modified so that systems and processes which
  # report late can do so.
  class CircularBuffer
    # Initialize the CircularBuffer object with the specified configuration.
    #
    # @param size [Integer] (1000) - The size of the buffer in object storage positions.
    # @param default_value [Object] (nil) - The default object with which to populate
    #                                       positions in the buffer.
    # @param thread_safe [Boolean] (true) - Enable thread safety so that multi-threaded callers can
    #                                       safely share a single circular buffer.
    def initialize(size: 1000, default_value: nil, thread_safe: true)
      raise 'Invalid buffer size' unless size.is_a? Integer

      @buffer = array_class(thread_safe).new
      @size_limit = size
      @buffer_index = @index = 0
      @default_value = default_value
      @buffer[@buffer_index] = default_value
    end

    # Append a value to the buffer by incrementing the current buffer index.
    #
    # @param value [Object] - The value to be stored.
    def append(value)
      self.index += 1
      @buffer[@buffer_index] = value
    end

    # Insert a value at the current buffer index.
    #
    # @param value [Object] - The value to be stored.
    def insert(value)
      @buffer[@buffer_index] = value
    end

    # Read the value stored at a specific index.
    #
    # @param requested_index [Integer] - The buffer index id to read.
    def read(requested_index)
      @buffer[target_index(requested_index)]
    end

    # Read a slice of the buffer in order by external index.
    #
    # @param start_index [Integer] - The index ID to start slicing from.
    # @param end_index [Integer] - The index ID to end slicing at.
    # @return [Array]
    def read_slice(start_index, end_index)
      self.index = end_index unless end_index < @index

      collection = []
      if target_index(start_index) > target_index(@index)
        collection += @buffer.slice(target_index(start_index)..(@size_limit - 1))
        collection += @buffer.slice(0..target_index(@index))
      else
        collection = @buffer.slice(target_index(start_index)..target_index(@index))
      end
      collection
    end

    # Advance the index by the specified number of positions.
    #
    # @param count [Integer] - The number of index positions to advance the current index
    def advance(count = 1)
      raise 'Invalid index advancement value' unless count.is_a? Integer

      self.index += count
    end

    attr_reader :index

    # Set the current index value of the buffer.  If the index has advanced more
    # than a single position, fill the intermediate positions with the default value.
    #
    # @param index [Integer] - The target index value.
    # @
    def index=(index)
      return if @index == index
      raise 'Invalid index: not an integer value' unless index.is_a? Integer
      raise 'Invalid index: rewind not allowed' if index < @index

      delta = index - @index
      previous_buffer_index = @buffer_index

      @index = index
      @buffer_index = index % @size_limit

      reset_values_between_indexes(previous_buffer_index, delta)
    end

    # Retrieve the current actual length of the internal buffer.
    #
    # @todo This is only used in unit tests so it feels like this method should
    #       be replaced with an alternative test mechanism.
    #
    # @return [Integer]
    def internal_buffer_length
      @buffer.length
    end

    protected

    # Reset the values between a previous index and a new index to the default
    # value.
    #
    # @param previous_buffer_index [Integer] - The most recent but not current buffer index.
    # @param delta [Integer] - The delta between the previous buffer index and current buffer index.
    def reset_values_between_indexes(previous_buffer_index, delta)
      case true
      when delta > @size_limit
        reset_values(0, @size_limit)
      when previous_buffer_index == @size_limit - 1
        reset_values(0, @buffer_index)
      else
        reset_values(previous_buffer_index + 1, @buffer_index)
      end
    end

    # Reset a range within the buffer to the default value.
    #
    # @todo Optimize edge cases such as a range that includes the entire buffer.
    def reset_values(range_start, range_end)
      # If the buffer is going to wrap, reset from the range start to the end of
      # the buffer and from the buffer start to the end of the range.
      if range_start > range_end
        @buffer.fill(@default_value, range_start..@size_limit)
        @buffer.fill(@default_value, 0..range_end)
      else
        @buffer.fill(@default_value, range_start..range_end)
      end
    end

    # Determine the target buffer index based on the external index.
    #
    # @param requested_index [Integer] - The index a target is requested for.
    # @return [Integer]
    def target_index(requested_index)
      raise "Invalid index (#{requested_index}): beyond range" \
        if requested_index > @index

      delta = @index - requested_index
      raise "Invalid index (#{requested_index}): below range" \
        if delta >= @size_limit

      @buffer_index - delta
    end

    # Return the proper class to use for the Array object.
    #
    # @return [Class]
    def array_class(thread_safe)
      return Concurrent::Array if thread_safe

      Array
    end
  end
end
