# class: Connection
#
# This class handles the low level details of a tcp socket. It's a barebones
# pluggable system that pushes all implementation details into callbacks
require 'socket'
require 'wrack'
module Wrack
  class Connection
    attr_accessor :server, :port, :options

    def initialize(server = "", port = 6667, options = {})
      @server = server
      @port   = port
      @options = options
      @options[:sep] ||= "\r\n"
      @options[:select_timeout] ||= 0

      @known_callbacks = [:read, :write, :err, :connect, :disconnect]
      @callbacks = {}

      @known_callbacks.each { |callback| @callbacks[callback] = [] }
    end

    # Attempts to establish a tcp connection
    def connect
      @connection = TCPSocket.open(server, port)
      if @connection
        set_signals
        fire_callbacks(:connect)
      end
    end

    # Drop the connection to the server cleanly
    def disconnect
      if connected?
        fire_callbacks(:disconnect)
        @connection.close
        @connection = nil
      end
    end

    def connected?
      @connection and not @connection.closed?
    end

    def write(raw)
      fire_callbacks(:write, raw)
      @connection.print raw, @options[:sep]
    end

    # Poll socket for messages.
    def poll
      begin
        rsock, wsock, esock = Kernel.select([@connection], nil, [@connection], @options[:select_timeout])

        if esock and esock.length > 0
          $stderr.puts "Wrack::Connection#poll reported socket error, disconnecting."
          disconnect
          nil
        end

        if rsock and rsock.length > 0
          raw = rsock[0].gets.chomp
          fire_callbacks(:read, raw)
        end
      rescue IOError => e
        if @signal_exit
          nil
        else
          raise e
        end
      end
    end

    def register_callback(context, callback_types, &block)

      # Smash all types into a single array
      callback_types = [callback_types].flatten

      unless callback_types.all? {|c| @known_callbacks.include? c}
        raise ArgumentError, "Attempted to register callback with unknown type(s) #{callback_types}"
      end

      callback_types.each do |callback_type|
        @callbacks[callback_type] << {:block => block, :context => context}
      end
    end

    private

    def fire_callback(callback_hash, *args)
      begin
        # XXX Instead of callback.call, perhaps this:
        #
        #     @context.instance_exec *args
        #
        # Doing instance_exec would remove the need to pass in connection
        # explicitly

        context = callback_hash[:context]
        block = callback_hash[:block]

        context.instance_exec(args, &block)
      rescue => details
        $stderr.puts "Error with callback #{block}: #{details}"
        $stderr.puts details.backtrace
      end
    end

    def fire_callbacks(callback_type, *args)
      @callbacks[callback_type].each do |callback_hash|
        fire_callback(callback_hash, *args)
      end
    end

    # Convenience method to set signal handlers to terminate a connection
    # This is implemented outside of the connect method so that classes
    # reimplementing the connect method can just call this instead of calling
    # the super method
    def set_signals
      %w{INT TERM QUIT}.each do |signal|
        Signal.trap(signal) do
          @signal_exit = true
          disconnect
          Signal.trap(signal, "DEFAULT")
        end
      end
    end
  end
end
