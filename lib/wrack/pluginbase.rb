# Defines the class methods that backs plugin generated
#
# This is necessary to make the class level DSL function

require 'wrack'

module Wrack
  module PluginBase
    attr_reader :bare_receivers
    def receive(options = {}, &block)
      # XXX will the self context be all fucked for this?
      # Do we need to pass in the instance that is defined in, somehow?
      @bare_receivers ||= []
      @bare_receivers << {:options => options, :block => block}
    end
  end
end
