# It's the plugin plugin!

require 'wrack'
module Wrack
  module Plugin
    class Plugin
      include Wrack::PluginBase
      receive do
        restrict :message => /^!plugin/
        receive do
          restrict :message => /reload/
          match { |msg| reload(msg) }
        end

        receive do
          restrict :message => /list/
          match { |msg| list(msg) }
        end

        receive do
          restrict :message => /destroy\s+(\S+)/
          match { |msg| destroy(msg) }
        end
      end

      def list(msg)
        privmsg msg.sender, "--- Registered plugins ---"
        Wrack::Plugin.registered.each do |plugin|
          privmsg msg.sender, "#{plugin} -> #{plugin.object_id}"
        end
      end

      def reload(msg)
        privmsg msg.sender, "Reloading all plugins"
        Wrack::Plugin.loader.load_all!
        bot.reload_plugins!
      end

      def destroy(msg)
        msg.message.match /destroy\s+(\S+)/
        privmsg msg.sender, "Destroying #{$1}"

        sym = $1.intern
        klass = Wrack::Plugin.get_plugin sym
        bot.manager.unload_plugin klass
        Wrack::Plugin.destroy sym
      end
    end
  end
end
