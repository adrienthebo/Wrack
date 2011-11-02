
module Wrack
  module Plugin
    class Connection
      include Wrack::PluginBase

      on_initialize do
        connection.register_callback(self, :connect) do
          nick bot.user.nick
          user bot.user.realname, bot.user.hostname, bot.user.servername, bot.user.fullname
        end

        connection.register_callback(self, :disconnect) do
          puts "Connection to #{connection.server} closed."
        end
      end

      receive do
        restrict :command => "443"
        match do
          disconnect
        end
      end

      receive do
        restrict :command => "ping"
        match do |msg|
          pong msg.params
        end
      end
    end
  end
end
