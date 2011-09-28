# Implements a threaded architecture to handle concurrent processing
# at the cost of potentially threadbombing a host.
#
# Deal with it. B)
#
# Perhaps a worker pool would be the correct model for this. Perhaps not.
require 'thread'
module Wrack
  class Connection
    def background!
      Thread.new do
        loop do
          poll
        end
      end
    end

    private

    # Reimpements the fire_callbacks to be threaded.
    def fire_callback(callback, msg)
      Thread.new do
        begin
          callback.call(self, msg)
        rescue => details
          $stderr.puts "Error with callback #{callback}: #{details}"
          $stderr.puts details.backtrace
        end
      end
    end
  end
end
