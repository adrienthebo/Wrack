# Implements the base requirements for wrack plugins.
#
# Performs automatic registration so that all available plugins can be
# automatically accessed.
#
# Generates the necessary functionality for other classes to instantiate
# plugin instances.

module Wrack
  module Plugin
    # Does this need to include the following to make plugins automagic?
    include Wrack::IRC::Commands

    # Register all plugins upon creation
    def self.included(klass)
      @klasses ||= []
      @klasses << klass
    end

    # Expose all registered plugins
    def self.registered
      @klasses.dup
    end

    # Provide default constructor
    # XXX Will this even work?
    #
    # Am I on crack?
    #
    #def initialize(restrictions = {})
    #  @restrictions = {}
    #end

    # Allow plugins to access the instantiating bot
    attr_accessor :bot
    def receive(&block)
      puts "I am #{self.inspect}"
    end
  end
end
