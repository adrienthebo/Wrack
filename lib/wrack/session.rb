# The actual IRC implementation class. Pulls in the connection and IRC
# implementation details
#
# If you're looking for a complete bot, this should be the place
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

    def receive(&block)
      receiver = Wrack::IRC::Receiver.new(&block)
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
        message = Wrack::IRC::Message.parse(raw)

        if message.nil?
          $stderr.puts "THIS IS A SHIT MESSAGE. FIX ME"
        else
          if @callbacks[message.command]
            @callbacks[message.command].each do |callback|
              callback.notify(message)
            end
          end

          puts "going to call receivers with message #{message.inspect}"
          @receivers.each {|receiver| receiver.notify(message) }
        end
      end
    end
  end
end

