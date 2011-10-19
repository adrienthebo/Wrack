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
        begin
          poll while connected?
        rescue => e
          $stderr.puts "Error while background polling: #{e}"
          $stderr.puts e.backtrace
        end
      end
    end

    protected

    def fire_callbacks(callback_type, *args)
      @callbacks[callback_type].each do |callback_hash|
        Thread.new do
          begin
            fire_callback(callback_hash, *args)
          rescue => e
            $stderr.puts "Error while triggering callback: #{e}"
            $stderr.puts e.backtrace
          end
        end
      end
    end
  end
end
