module Wrack
  module Callback
    class Ping
      def call(connection, msg)
        if msg =~ /^PING :(.*)/i
          servers = $1.split(" ")
          connection.write("PONG #{servers[0]}")
        end
      end
    end
  end
end
