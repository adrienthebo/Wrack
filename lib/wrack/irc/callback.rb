# IRC level callback
#
# Given an irc message
module Wrack
  module IRC
    class Callback
      attr_reader :command
      def initialize(command, options = {}, &block)
        @command = command
        @options = options
        @block   = block
      end

      def notify(msg)

        interested = @options.keys.all? do |method|
          should = @options[method]
          msg.respond_to?(method) and msg.send(method).match(should)
        end

        @block.call(msg) if interested
      end
    end
  end
end
