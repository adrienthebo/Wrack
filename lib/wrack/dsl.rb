# Wrack DSL
#
# Because yaml is hard, and DSLs are cheap
require 'wrack'
module Wrack
  class Session

    def self.bot(options = {}, &block)
      self.new(options).instance_eval &block
    end

    def connection(&block)
      yield @connection
    end
  end
end
