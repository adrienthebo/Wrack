# Generates wrapper objects
module Wrack
  module IRC
    class Message
      attr_reader :prefix, :command, :params

      def self.parse(msg)
        if msg.match(/^:(\S+)\s+(\S+)\s*(.*)/)
          new($1, $2, $3)
        end
      end

      private

      def self.new(prefix, command, params)
        @prefix  = prefix
        @command = command.intern
        @params  = params
      end
    end
  end
end
