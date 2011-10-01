# Implements a threaded architecture to handle concurrent processing
# at the cost of potentially threadbombing a host.
#
# Deal with it. B)
#
# Perhaps a worker pool would be the correct model for this. Perhaps not.
require 'thread'
require 'wrack'
module Wrack
  class Connection
    def background!
      Thread.new do
        poll while connected?
      end
    end

    protected

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
