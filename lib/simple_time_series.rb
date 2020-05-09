# frozen_string_literal: true

require_relative 'simple_time_series/integer_circular_buffer'

# Implements a simple, incremental circular buffer time series data store.
#
# @notes
# The time series is stored in one-second granularity based on Unix
# timestamps.  Increment is offered, but decrement is not.  The time series
# cannot be rewound to increment previous time indexes and is intended for
# realtime gathering of data.
#
# @todo offer an interface that operates on DateTime objects rather than Unix
# timestamps directly.
#
# @todo thread safety is implemented via the heavy-handed concurrent-ruby.  It
# should be possible to optimize performance with a simpler implementation of a
# thread safe circular buffer.
#
# @todo replace the internal circular buffer implementation with a simple
# community-supported time series or circular buffer storage object.  Nobody
# should be writing their own except as an exercise.
class SimpleTimeSeries
  # Initialize the time series object, including the underlying buffer.
  #
  # @param size [Integer] (300) - The size of time series (in seconds).
  # @param thread_safe [Boolean] (true) - Utilize a thread safe buffer.  This has performance penalties.
  def initialize(size: 300, thread_safe: true)
    raise 'Invalid time series size' unless size.is_a? Integer

    @integer_buffer = IntegerCircularBuffer.new(
      size: size,
      thread_safe: thread_safe
    )
  end

  # Increment the count for the current time.
  def increment
    increment_timestamp(Time.now.to_i)
  end

  # Increment a specific timestamp.  This may be used in systems which are reporting
  # in a delayed manner such as after batching actions.
  # @note the underlying storage does not support rewind.  If using this methd it is
  # the responsibility of the caller to make calls in chronological order.
  #
  # @param timestamp [Integer] - The timestamp for which to increment data.
  def increment_timestamp(timestamp)
    raise 'Invalid timestamp' unless timestamp.is_a? Integer

    @integer_buffer.index = timestamp
    @integer_buffer.increment
  end

  # Return the sum of events since the provided timestamp.
  #
  # @param start_timestamp [Integer] - The timestamp at which to start the report.
  # @return [Integer]
  def sum_since(start_timestamp)
    read_timeframe(start_timestamp, Time.now.to_i).sum
  end

  # Read the value at a given timestamp.  This may be used by the caller to validate
  # expected behavior.
  #
  # @param timestamp [Integer] - The timestamp for which to read the stored value.
  # @return [Integer]
  def read(timestamp)
    @integer_buffer.read(timestamp)
  end

  # Read a slice of values for a given timeframe.
  #
  # @param start_timestamp [Integer] - Timestamp for the start of the timeframe.
  # @param end_timestamp [Integer] - Timestamp for the end of the timeframe.
  # @return [Array]
  def read_timeframe(start_timestamp, end_timestamp)
    @integer_buffer.read_slice(start_timestamp, end_timestamp)
  end
end
