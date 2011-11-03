
module Wrack
  module Plugin
    class Logging
      include Wrack::PluginBase
      
      on_initialize do
        connection.register_callback(self, :write) {|raw| puts "\033[31m->\033[0m #{raw}" }
        connection.register_callback(self, :read) {|raw| puts "\033[32m<-\033[0m #{raw}" }
      end
    end
  end
end
