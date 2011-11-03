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
            e.backtrace.each { |line| privmsg msg.sender, line }
          end
        end
      end
    end
  end
end

