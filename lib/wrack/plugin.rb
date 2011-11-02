require 'wrack/pluginbase'
require 'wrack/pluginloader'

module Wrack
  module Plugin
    class << self
      def register(klass)
        @klasses ||= []
        @klasses << klass
      end

      def registered
        (@klasses ||= []).dup
      end

      def unload(sym)
        const_remove sym
        const_set sym, Class.new
      end

      def loader
        @loader ||= Wrack::PluginLoader.new
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
