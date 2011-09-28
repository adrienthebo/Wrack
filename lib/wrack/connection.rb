# class: Connection
# 
# Handles the raw details of a tcp socket
#
require 'socket'
class Wrack
  class Connection
    attr_accessor :server, :port, :options
    def initialize(server="", port=6667, options={})
      @server = server
      @port   = port
      @options = options
      @callbacks = {:read => [], :write => [], :err => []}

      @connected = false

    end

    # Attempts to establish a tcp connection
    def connect
      @connection = TCPSocket.new(server, port)
      if @connection
        @connected = true
      end
      # FIXME handle signals
    end

    # Drop the connection to the server cleanly
    def disconnect
      @connection.close
      @connection = nil
      @connected = false
    end

    # Are we connected?
    # This is kind of optimistic. Phucket.
    def connected?
      @connected
    end

    # Takes either an object that responds to a callback
    # or a block that receives a single argument
    def register_callback(type, callback = nil, &block)
      blob = (callback || block)
      @callbacks[type] << blob
    end

    def write(msg)
      fire_callbacks(:write, msg)
      @connection.puts(msg)
    end

    # Poll socket for messages.
    def poll
      rsock, wsock, esock = Kernel.select([@connection], nil, [@connection], options[:select_timeout])

      if esock.length > 0
        # XXX This is shit. Fix.
        $stderr.puts("Generic vague socket error message!")
        disconnect
      end

      if rsock.length > 0
        msg = rsock[0].gets
        fire_callbacks(:read, msg)
      end
    end

    private

    def fire_callbacks(type, msg)
      @callbacks[type].each do |callback|
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
