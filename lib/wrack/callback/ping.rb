class Wrack
  module Callback
    class Ping
      def call(connection, msg)
        if msg =~ /^PING/i
          connection.write("PONG")
        end
      end
    end
  end
end
