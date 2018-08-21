# coding: utf-8

# A queue for compiler objects between parser layers.

require_relative "parse_queue/exceptions"
require_relative "parse_queue/version"

class ParseQueue

  # The current read point of the queue.
  attr_reader :position

  # The number of items removed from the queue.
  attr_reader :offset

  # Set up the parser queue.
  def initialize(&fetch)
    @fetch = fetch || lambda { false }
    @buffer = []
    @offset = @position = 0
  end

  # How many items are in this parse queue?
  def count
    @buffer.length - @position + @offset
  end

  # Manually add items to the buffer
  def add(*items)
    @buffer += items.flatten
  end

  # Get an item from the buffer.
  def get
    if @position >= (@buffer.length + @offset)
      item = @fetch.call
      fail ParseQueueNoFwd unless item
      @buffer << item
    end

    result = @buffer[@position - @offset]
    @position += 1
    result
  end

  # Set the position
  def position=(value)
    @position = value
    validate_position
  end

  # Undo the last get.
  def back_up
    @position -= 1
    validate_position
  end

  # Release any items before the current item.
  def shift
    @buffer.shift(@position - @offset)
    @offset = @position
  end

  # Try to process some items with roll back on failure.
  def try(&block)
    save = @position
    @position = save unless block.call
    validate_position
  end

  # Try to process some items with shift of success and roll back on failure.
  def try!(&block)
    save = @position

    if block.call
      shift
    else
      @position = save
      validate_position
    end
  end

  # Is this a valid position?
  def validate_position
    fail ParseQueueNoRev if @position < @offset
    fail ParseQueueNoFwd if @position >= (@buffer.length + @offset)
  end

end
