# Implements the base requirements for wrack plugins.
#
# Performs automatic registration so that all available plugins can be
# automatically accessed.
#
# Generates the necessary functionality for other classes to instantiate
# plugin instances.

require 'wrack'
require 'wrack/irc'
require 'wrack/plugin'
require 'wrack/receiver'
require 'wrack/pluginloader'

module Wrack

  module PluginBase

    # Defines the class methods that backs plugin generated
    #
    # This is necessary to make the class level DSL function
    module ClassMethods
      def receive(restrictions = {}, &block)
        bare_receivers << {:restrictions => restrictions, :block => block}
      end

      def on_initialize(&block)
        initializers << block
      end

      def bare_receivers
        @bare_receivers ||= []
      end

      def initializers
        @initializers ||= []
      end
    end

    include Wrack::IRC::Commands

    # Modify all plugins to include the class level methods, and register
    # them for subsequent lookup
    def self.included(klass)
      klass.extend Wrack::PluginBase::ClassMethods
      # XXX Make this a manual operation if not using a hot plugin?
      #Wrack::Plugin.register klass
    end

    attr_accessor :receivers
    attr_accessor :connection
    attr_accessor :bot

    # Defines a default constructor to copy all receivers generated during
    # class instantiation into the object
    def initialize(connection, bot, restrictions = {})
      @connection = connection
      @bot        = bot
      @receivers  = []

      # Instantiate all class level receivers for this instance
      self.class.bare_receivers.each do |r|
        receiver = Wrack::Receiver.new(self, r[:restrictions].merge(restrictions), &r[:block])
        @receivers << receiver
      end

      # Evaluate all instance blocks
      self.class.initializers.each do |block|
        instance_exec &block
      end
    end
  end
end
