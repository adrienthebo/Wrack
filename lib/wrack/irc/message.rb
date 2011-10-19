# Generates wrapper objects
module Wrack
  module IRC
    class Message
      attr_reader :prefix, :command, :params, :raw

      def self.parse(raw)

        # Attempt to match any subclass methods against this
        if @subclasses and can_parse = @subclasses.find {|sub| sub.parse(raw)}
          can_parse.parse(raw)
        elsif raw.match(/^(?::(\S+)\s+)?(\S+)\s*(.*)/)
          new(:prefix => $1, :command => $2, :params => $3, :raw => raw)
        end
      end

      def self.inherited(klass)
        @subclasses ||= []
        @subclasses << klass
      end

      protected :initialize
      def initialize(options = {})
        @command = canonize(options[:command])
        @params  = options[:params]
        @prefix  = options[:prefix]
        @raw     = options[:raw]
      end

      def canonize(name)
        if name.is_a? String
          name.downcase.intern
        else
          name
        end
      end

      class Privmsg < Wrack::IRC::Message
        attr_reader :sender, :message, :command
        def self.parse(raw)
          if raw.match(/^(?::(\S+)\s+)?privmsg\s+(\S+)\s+:(.*)/i)
            new(:prefix => $1, :command => :privmsg, :sender => $2, :message => $3)
          end
        end

        def initialize(options = {})
          super(options)
          @sender  = options[:sender]
          @message = options[:message]
        end
      end
    end
  end
end
