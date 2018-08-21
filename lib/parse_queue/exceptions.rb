# coding: utf-8

# Exception types for the parse queue.

# The base error class for the parse queue.
class ParseQueueError < StandardError
end

# Raised when no more data is available.
class ParseQueueNoData < ParseQueueError
end

# Raised when no back up data exists.
class ParseQueueBackUp < ParseQueueError
end

