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

      # See if we should turn on logging
      if options[:logging]
        @connection.register_callback [:read, :write] do |connection, raw|
          puts raw
        end
      end

      # Initialize IRC level callback mechanism
      @connection.register_callback(:read) do |connection, raw|
        message = Wrack::IRC::Message.parse(raw)

        if @callbacks[message.command]
          @callbacks[message.command].each do |callback|
            callback.call(message)
          end
        end
      end

      on :ping do |msg|
        pong(msg.params)
      end
    end

    def connect
      @connection.connect
    end

    def on(command, options = {}, &block)
      @callbacks[command] ||= []
      @callbacks[command] << block
    end
  end
end

