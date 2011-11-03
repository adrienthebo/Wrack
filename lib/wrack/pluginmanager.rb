# Abstraction on top of a raw Wrack::Connection to manage IRC plugins
require 'wrack'
require 'wrack/irc'
module Wrack
  class PluginManager
    attr_reader :connection
    def initialize(options = {})
      @connection = (options[:connection] || Wrack::Connection.new)
      @plugins    = []

      # Initialize IRC level callback mechanism
      connection.register_callback(self, :read) {|raw| on_read(raw) }
    end

    def load_plugin(klass, bot)
      @plugins << klass.new(@connection, bot)
    end

    def unload_plugin(klass)
      targets = @plugins.select {|plugin| plugin.is_a? klass}
      @plugins -= targets
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

