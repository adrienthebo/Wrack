# Generates wrapper objects
module Wrack
  module IRC
    class Message
      attr_reader :prefix, :command, :params

      def self.parse(msg)
        if msg.match(/^:(\S+)\s+(\S+)\s*(.*)/)
          new($1, $2, $3)
        else
          raise "FUCK"
        end
      end

      private

      def initialize(prefix, command, params)
        @prefix  = prefix
        @command = command.downcase.intern
        @params  = params
      end
    end
  end
end
