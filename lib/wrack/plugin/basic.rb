
module Wrack
  module Plugin
    class Basic
      include Wrack::Plugin

      receive do
        restrict :message => /join (?:#\S+)/

        match do |msg|
          msg.message.match(/join\s+(#.*)/)
          join $1
        end
      end

      receive do
        restrict :message => /part (?:#\S+)/

        match do |msg|
          msg.message.match(/part\s+(#.*)/)
          part $1
        end
      end

      receive do
        restrict :message => "quit"

        match do |msg|
          quit
        end
      end

      receive do
        restrict :message => /nick (?:\S+)/

        match do |msg|
          msg.message.match(/nick\s+(.*)/)
          nick $1
        end
      end

      receive do
        restrict :message => /privmsg (?:#\S+)\s+(:?.+)/

        match do |msg|
          msg.message.match(/nick\s+(.*)\s+(.+)/)
          privmsg $1, $2
        end
      end
    end
  end
end
