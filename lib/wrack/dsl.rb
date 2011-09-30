# Wrack DSL
#
# Because yaml is hard, and DSLs are cheap
require 'wrack'
module Wrack
  class Bot
    def initialize(&block)
      @connection = Wrack::Connection.new
      instance_eval &block
    end

    def connection(&block)
      yield @connection
    end

    def connect
      @connection.connect
    end

    def register_callback(*args)
      @connection.register_callback(*args)
    end
  end
end
