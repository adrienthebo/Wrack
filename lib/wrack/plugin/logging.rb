
module Wrack
  module Plugin
    class Logging
      include Wrack::PluginBase
      
      on_initialize do
        connection.register_callback(self, :write) {|raw| puts "-> #{raw}" }
        connection.register_callback(self, :read)  {|raw| puts "<- #{raw}" }
      end
    end
  end
end
