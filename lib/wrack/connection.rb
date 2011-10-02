# class: Connection
#
# This class handles the low level details of a tcp socket. It's a barebones
# pluggable system that pushes all implementation details into callbacks
require 'socket'
module Wrack
  class Connection
    attr_accessor :server, :port, :options

    def initialize(server="", port=6667, options={})
      @server = server
      @port   = port
      @options = options
      @callbacks = {:read => [], :write => [], :err => []}
    end

    # Attempts to establish a tcp connection
    def connect
      @connection = TCPSocket.new(server, port)
      if @connection

        %w{INT TERM QUIT}.each do |signal|
          Signal.trap(signal) do
            disconnect
            Signal.trap(signal, "DEFAULT")
          end
        end
      end
    end

    # Drop the connection to the server cleanly
    def disconnect
      if connected?
        @connection.close
        @connection = nil
      end
    end

    def connected?
      @connection and not @connection.closed?
    end

    def write(raw)
      fire_callbacks(:write, raw)
      @connection.puts(raw)
    end

    # Poll socket for messages.
    def poll
      begin
        rsock, wsock, esock = Kernel.select([@connection], nil, [@connection], options[:select_timeout])

        if esock.length > 0
          # XXX This is shit. Fix.
          $stderr.puts("Generic vague socket error message!")
          disconnect
        end

        if rsock.length > 0
          raw = rsock[0].gets.chomp
          fire_callbacks(:read, raw)
        end
      rescue IOError
        puts "Socket got face stabbed"
      end
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
        return callback_type.each { |sym| register_callback(sym, options, &block) }
      when Symbol
        unless [:read, :write, :err].include? callback_type
          raise ArgumentError, "register_callback requires a callback_type of either :read, :write, :err, or array thereof."
        end
      end

      blob = if block_given?
        block
      else
        options[:callback]
      end
      @callbacks[callback_type] << blob
    end

    private

    # TODO Add the ability to pass a module/class/block to this and have
    # The Right Thing be done.
    def fire_callback(callback, raw)
      begin
        callback.call(self, raw)
      rescue => details
        $stderr.puts "Error with callback #{callback}: #{details}"
        $stderr.puts details.backtrace
      end
    end

    def fire_callbacks(type, raw)
      @callbacks[type].each do |callback|
        fire_callback(callback, raw)
      end
    end
  end
end
