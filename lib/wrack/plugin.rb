require 'wrack/pluginbase'
require 'wrack/loader'

module Wrack
  module Plugin
    class << self

      # Register a plugin class
      def register(klass)
        @klasses ||= []
        @klasses << klass
      end

      # Return a list of all plugin classes
      def registered
        (@klasses ||= []).dup
      end

      def get_instance(sym)
        const_get(sym).new
      end

      # Destroy a plugin class and associated constants
      def destroy(sym)
        klass = const_get sym
        @klasses.delete klass
        remove_const sym
        const_set sym, Class.new
      end

      def loader
        @loader ||= Wrack::Loader.new
      end

      def newplugin(sym, &block)
        klass = Class.new
        # XXX This is dirty.
        klass.class_eval { include Wrack::PluginBase }
        klass.class_eval &block
        register klass
        const_set sym, klass
      end
    end
  end
end
