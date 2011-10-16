# Abstraction on top of a raw Wrack::Connection to manage IRC plugins
require 'wrack'
require 'wrack/irc'
module Wrack
  class PluginManager
    include Wrack::IRC::Commands

    attr_reader :connection
    def initialize(options = {})
      @connection = (options[:connection] || Wrack::Connection.new)
      @plugins    = []

      # See if we should turn on logging
      register_logger if options[:logging]

      # Initialize IRC level callback mechanism
      register_read_handler
    end

    def register_plugin(plugin)
      @plugins << plugin
    end

    def unregister_plugin(plugin)
      @plugins.delete plugin
    end

    private

    def register_logger
      @connection.register_callback([:read, :write]) {|connection, raw| puts raw }
    end

    def register_read_handler
      @connection.register_callback(:read) {|connection, raw| on_read(raw) }
    end

    def on_read(raw)
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

