# Implements the base requirements for wrack plugins.
#
# Performs automatic registration so that all available plugins can be
# automatically accessed.
#
# Generates the necessary functionality for other classes to instantiate
# plugin instances.

require 'wrack/irc'
require 'wrack/receiver'
require 'wrack/pluginbase'

module Wrack
  module Plugin
    # Does this need to include the following to make plugins automagic?
    include Wrack::IRC::Commands

    # Register all plugins upon creation
    def self.included(klass)
      klass.extend Wrack::PluginBase
      @klasses ||= []
      @klasses << klass
    end

    # Expose all registered plugins
    def self.registered
      @klasses.dup
    end

    attr_accessor :bot

    def initialize(restrictions = {})
      @receivers = []
      self.class.bare_receivers.each do |r|
        # TODO merge class level restrictions and r[:options]
        receiver = Wrack::Receiver.new(self, r[:options], &r[:block])
        @receivers << receiver
      end
      @restrctions = restrictions
    end
  end
end
