# coding: utf-8

# A queue for compiler objects between parser layers.

require_relative "parse_queue/exceptions"
require_relative "parse_queue/version"

class ParseQueue

  # The current read point of the queue.
  attr_reader :position

  # Set up the parser queue.
  def initialize(&fetch)
    @fetch = fetch || lambda { false }
    @buffer = []
    @position = 0
  end

  # How many items are in this parse queue?
  def count
    @buffer.length
  end

  # Manually add items to the buffer
  def add(*items)
    @buffer += items.flatten
  end

  # Get an item from the buffer.
  def get
    if position >= @buffer.length
      item = @fetch.call
      fail ParseQueueNoData unless item

      @buffer << item
    end

    result = @buffer[position]
    @position += 1
    result
  end

end
