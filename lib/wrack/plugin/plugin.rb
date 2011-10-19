# It's the plugin plugin!

require 'wrack'
module Wrack
  module Plugin
    class Plugin
      include Wrack::Plugin
      receive do
        restrict :message => /^!plugin/

        receive do
          restrict :message => /reload/
          match do |msg|
            paths = Wrack::Plugin.paths.dup

            paths.each do |path|
              privmsg msg.sender, "Reloading #{path}" 
              Wrack::Plugin.load path
            end
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
