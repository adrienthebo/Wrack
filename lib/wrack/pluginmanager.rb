# Abstraction on top of a raw Wrack::Connection to manage IRC plugins
require 'wrack'
require 'wrack/irc'
module Wrack
  class PluginManager
    attr_reader :connection
    def initialize(options = {})
      @connection = (options[:connection] || Wrack::Connection.new)
      @plugins    = []

      # See if we should turn on logging
      if options[:logging]
        connection.register_callback(self, :read)  {|raw| puts "<- #{raw}" }
        connection.register_callback(self, :write) {|raw| puts "-> #{raw}" }
      end

      # Initialize IRC level callback mechanism
      connection.register_callback(self, :read) {|raw| on_read(raw) }
    end

    def register_plugin(plugin)
      @plugins << plugin
    end

    def unregister_plugin(plugin)
      @plugins.delete plugin
    end

    private

    def on_read(raw)
      raw = raw[0]
      if message = Wrack::IRC::Message.parse(raw)
        @plugins.each do |plugin|
          plugin.receivers.each {|receiver| receiver.notify(message) }
        end
      else
        $stderr.puts "Mangled message received: #{raw}"
      end
    end
  end
end

