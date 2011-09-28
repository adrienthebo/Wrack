# class: Connection
#
# This class handles the low level details of a tcp socket. It's a barebones
# pluggable system that pushes all implementation details into callbacks
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

        %w{INT TERM QUIT}.each do |sig|
          trap sig { disconnect }
        end
      end
    end

    # Drop the connection to the server cleanly
    def disconnect
      @connection.close
      @connection = nil
      @connected = false
    end

    def connected?
      @connected
    end

    # Takes either an object that responds to a callback or a block that
    # receives a single argument
    def register_callback(callback_type, options = {}, &block)

      # Validate type
      case callback_type
      when Array
        # If we've been given an array of types to apply the callback,
        # recursively call them all
        # FIXME Return early? Really?
        return callback_type.each { |sym| register_callback(sym, options) }
      when Symbol
        unless [:read, :write, :err].include? callback_type
          raise ArgumentError, "register_callback requires a callback_type of either :read, :write, :err, or array thereof."
        end
      end

      blob = (options[:callback] || block)
      @callbacks[callback_type] << blob
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
