# Implements the base requirements for wrack plugins.
#
# Performs automatic registration so that all available plugins can be
# automatically accessed.
#
# Generates the necessary functionality for other classes to instantiate
# plugin instances.

require 'wrack/irc'
require 'wrack/receiver'

module Wrack

  # Defines the class methods that backs plugin generated
  #
  # This is necessary to make the class level DSL function
  module PluginBase
    attr_reader :bare_receivers
    def receive(options = {}, &block)
      # XXX will the self context be all fucked for this?
      # Do we need to pass in the instance that is defined in, somehow?
      @bare_receivers ||= []
      @bare_receivers << {:options => options, :block => block}
    end
  end

  module Plugin
    include Wrack::IRC::Commands

    # Modify all plugins to include the class level methods, and register
    # them for subsequent lookup
    def self.included(klass)
      klass.extend Wrack::PluginBase
      @klasses ||= []
      @klasses << klass
    end

    # Expose all registered plugins
    def self.registered
      @klasses.dup
    end

    attr_accessor :receivers
    attr_accessor :connection

    # Defines a default constructor to copy all receivers generated during
    # class instantiation into the object
    def initialize(restrictions = {})
      @receivers = []
      self.class.bare_receivers.each do |r|
        # TODO merge class level restrictions and r[:options]
        receiver = Wrack::Receiver.new(self, r[:options], &r[:block])
        @receivers << receiver
      end
      @restrictions = restrictions
    end
  end
end
