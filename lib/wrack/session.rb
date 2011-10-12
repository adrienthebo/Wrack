# Assembles the higher level components of an IRC connection on top of a raw
# socket. Manages callbacks and maintains the connection.
require 'wrack'
require 'wrack/irc'
module Wrack
  class Session
    include Wrack::IRC::Commands

    def initialize(options = {})
      @connection = (options[:connection] || Wrack::Connection).send(:new)
      @callbacks  = {}
      @receivers  = []

      # See if we should turn on logging
      register_logger if options[:logging]

      # Initialize IRC level callback mechanism
      register_message_handler

      on :ping do |msg|
        pong(msg.params)
      end
    end

    def connect
      @connection.connect
    end

    def disconnect
      quit
      @connection.disconnect
    end

    def receive(context, &block)
      receiver = Wrack::Receiver.new(context, &block)
      @receivers << receiver
    end

    def on(command, options = {}, &block)
      callback = Wrack::IRC::Callback.new(command, options, &block)
      @callbacks[command] ||= []
      @callbacks[command] << callback
    end

    private

    def register_logger
      @connection.register_callback [:read, :write] do |connection, raw|
        puts raw
      end
    end

    def register_message_handler
      @connection.register_callback(:read) do |connection, raw|
        if message = Wrack::IRC::Message.parse(raw)

          # Check to see if we have any standalone callbacks that respond to
          # this message, and if so call them.
          #
          # This extra validation is necessary since callbacks can be
          # registered for arbitrary message types
          if @callbacks[message.command]
            @callbacks[message.command].each {|callback| callback.notify(message) }
          end

          # Call all receivers on this message.
          @receivers.each {|receiver| receiver.notify(message) }
        else
          $stderr.puts "Mangled message received: #{raw}"
        end
      end
    end
  end
end

