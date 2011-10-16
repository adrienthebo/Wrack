# Implements an SSL connection
require 'socket'
require 'openssl'
module Wrack
  class Connection
    class SSL < Connection

      def initialize(server="", port=6667, options={})
        puts "In Wrack::Connection::SSL.initialize"
        super
      end

      # We generate a tcp socket using the base class, and then stuff in
      # the ssl stuff and then swap out @connection
      def connect
        puts "In Wrack::Connection::SSL#connect"
        @connection = TCPSocket.new(server, port)
        @connection = OpenSSL::SSL::SSLSocket.new(@connection)
        @connection.connect
        require 'pp'
        pp @connection
        if @connection
          set_signals
        end
      end
      def connect
        super
      end
    end
  end
end
