# Abstraction on top of a raw Wrack::Connection to manage IRC level
# callbacks
require 'wrack'
require 'wrack/irc'
module Wrack
  class Session
    include Wrack::IRC::Commands

    attr_reader :connection
    def initialize(options = {})
      @connection = (options[:connection] || Wrack::Connection.new)
      @receivers  = []

      # See if we should turn on logging
      register_logger if options[:logging]

      # Initialize IRC level callback mechanism
      register_message_handler
    end

    # XXX REMOVE ME
    def connect
      @connection.connect
    end

    def disconnect
      @connection.disconnect
    end

    def receive(context, &block)
      receiver = Wrack::Receiver.new(context, &block)
      @receivers << receiver
    end

    private

    def register_logger
      @connection.register_callback [:read, :write] {|connection, raw| puts raw }
    end

    def register_read_handler
      @connection.register_callback(:read) {|connection, raw| on_read(raw) }
    end

    def on_read(raw)
      if message = Wrack::IRC::Message.parse(raw)
        # Call all receivers on this message.
        @receivers.each {|receiver| receiver.notify(message) }
      else
        $stderr.puts "Mangled message received: #{raw}"
      end
    end
  end
end

