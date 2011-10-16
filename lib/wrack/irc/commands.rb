# Basic IRC commands as defined by RFC 1459
module Wrack
  module IRC
    module Commands

      # 4.1 Connection registration
      def nick(nick)
        connection.write("NICK #{nick}")
      end

      def user(username, hostname, servername, fullname)
        connection.write("USER #{username} #{hostname} #{servername} :#{fullname}")
      end

      def quit(msg = nil)
        connection.write("QUIT" + (msg ? " :#{msg}" : ""))
        connection.disconnect
      end

      # This is part of the standard, but it's not relevant to my interests
      # to implement them now.
      [:oper, :server, :squit].each do |method|
        define_method(method) do |*args|
          raise NotImplementedError
        end
      end

      # 4.2 Channel operation
      def join(channel, key = nil)
        connection.write("JOIN #{channel}" + (key ? " #{key}" : ""))
      end

      def part(channel)
        connection.write("PART #{channel}")
      end

      def mode(target, mode)
        # TODO validate type and fail appropriately
        # if user, perhaps autofill that value?
        connection.write("MODE #{target} #{mode}")
      end

      # This is part of the standard, but it's not relevant to my interests
      # to implement them now.
      [:names, :list, :topic, :invite, :kick].each do |method|
        define_method(method) do |*args|
          raise NotImplementedError
        end
      end

      # 4.3 Server queries and commands
      # not implemented

      # 4.4 Sending messages

      def privmsg(recipient, msg)
        connection.write("PRIVMSG #{recipient} :#{msg}")
      end

      def notice(recipient, msg)
        connection.write("NOTICE #{recipient} :#{msg}")
      end

      # 4.5 User based queries
      # not implemented

      # 4.6 Miscellaneous messages

      def pong(server)
        connection.write("PONG #{server}")
      end
    end
  end
end
