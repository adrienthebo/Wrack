require 'wrack'
module Wrack
  module Plugin
    class Eval
      include Wrack::PluginBase
      receive do
        restrict :message => /^!eval/
        restrict :prefix => /finch/

        match do |msg|
          
          msg.message.match /^!eval (.*$)/
          begin 
            out = eval $1
            privmsg msg.sender, out.inspect
          rescue => e
            privmsg msg.sender, e
            $stderr.puts e
            $stderr.puts e.backtrace
          end
        end
      end
    end
  end
end

