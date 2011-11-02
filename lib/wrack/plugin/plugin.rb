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
          match do |msg|
            puts "Reloading all plugins"
            Wrack::Plugin.loader.reload_known_plugins!
            bot.reload_plugins!
          end
        end

        receive do
          restrict :message => /list/
          match do |msg|
            privmsg msg.sender, "--- Registered plugins ---"
            Wrack::Plugin.registered.each do |plugin|
              privmsg msg.sender, plugin
            end
          end
        end
      end
    end
  end
end
