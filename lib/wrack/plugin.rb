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

  module Plugin
    include Wrack::IRC::Commands

    class << self
      # Modify all plugins to include the class level methods, and register
      # them for subsequent lookup
      def included(klass)
        klass.extend Wrack::PluginBase
        @klasses ||= []
        @klasses << klass unless @klasses.include? klass
      end

      # Expose all registered plugins
      def registered
        @klasses.dup
      end

      def paths
        @paths ||= []
      end

      def load(path)
        paths << path
        Kernel.load path
      end

      def reload_all
        @paths.each { |path| Kernel.load path }
      end
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
