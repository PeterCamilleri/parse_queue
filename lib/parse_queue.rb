# The Ruby Compiler Toolkit Project - Parse Queue
# A queue for compiler objects between parser layers.

require_relative "parse_queue/exceptions"
require_relative "parse_queue/version"

class ParseQueue

  # The current read point of the queue.
  attr_reader :position

  #The default fetch block
  DFB = Proc.new { false }

  # Set up the parser queue.
  def initialize(&fetch)
    @fetch  = fetch || DFB
    @buffer = []
    @offset = @position = 0
  end

  # How many unread items are in this parse queue?
  def fwd_count
    index_limit - @position
  end

  # How many already read items are still in this parse queue?
  def rev_count
    @position - @offset
  end

  # Get an item from the buffer.
  def get
    if @position >= index_limit
      item = @fetch.call

      unless item
        @fetch = DFB
        fail ParseQueueNoFwd
      end

      @buffer << item
    end

    result = @buffer[rev_count]
    @position += 1
    result
  end

  # Fetch all possible items.
  def fetch_all
    loop do
      item = @fetch.call

      unless item
        @fetch = DFB
        return
      end

      @buffer << item
    end
  end

  # Set the position
  def position=(value)
    @position = value
    validate_position
  end

  # Undo the last get.
  def unget(count=1)
    @position -= count
    validate_position
  end

  # Release any items before the current item.
  def shift
    @buffer.shift(rev_count)
    @offset = @position
  end

  # Try to process some items with roll back on failure.
  def try(&block)
    save = @position
    self.position = save unless (result = block.call)
    result
  end

  # Process some items with a shift on success and a roll back on failure.
  def try!(&block)
    shift if (result = try(&block))
    result
  end

private

  # Is this a valid position?
  def validate_position
    fail ParseQueueNoRev if @position < @offset
    fail ParseQueueNoFwd if @position >= index_limit
  end

  # The first index past the end of the array
  def index_limit
    @buffer.length + @offset
  end
end
