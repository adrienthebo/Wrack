require 'wrack/pluginbase'
require 'wrack/loader'

module Wrack
  module Plugin
    class << self

      # Explicitly register a plugin class
      # This allows us to have unregistered system level plugins that work
      # alongside user created plugins but cannot be altered
      def register(klass)
        @klasses ||= []
        @klasses << klass
      end

      # Return a list of all plugin classes
      def registered
        (@klasses ||= []).dup
      end

      def get_plugin(sym)
        constant = canonize sym
        begin
          const_get(constant)
        rescue NameError => e
          $stderr.puts "No such plugin #{constant}"
          raise
          puts registered.inspect
        end
      end

      def get_instance(sym)
        get_plugin(sym).new
      end

      # Destroy a plugin class and associated constants
      def destroy(sym)
        klass = get_plugin sym
        @klasses.delete klass
        remove_const canonize sym
      end

      def loader
        @loader ||= Wrack::Loader.new
      end

      def newplugin(sym, &block)
        if self.constants.include? canonize(sym)
          $stderr.puts "#{klass} already loaded, not reloading"
        else
          klass = Class.new
          # XXX This is dirty.
          klass.class_eval { include Wrack::PluginBase }
          klass.class_eval &block
          register klass

          const_set canonize(sym), klass
          get_plugin sym
        end
      end

      def canonize(sym)
        sym.to_s.capitalize.intern
      end
    end
  end
end
