module Wrack
  module Callback
    class Log
      def call(connection, msg)
        puts msg
      end
    end
  end
end
