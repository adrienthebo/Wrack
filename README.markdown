Wrack
=====

Because everything should be a plugin

Example bot config
------------------

    require 'wrack'

    navoc = Wrack::Bot.new do
      configure_server do |s|
        s.server = "irc.freenode.net"
        s.port   = 6667
      end
    
      configure_user do |u|
        u.nick       = "mybot"
    
        u.realname   = "wopr"
        u.hostname   = "localhost"
        u.servername = "localhost"
        u.fullname   = "Raaawr robots!"
      end
    
      register RobotPlugin
    end
    
    navoc.run!

Example plugin
--------------

    # Yes, this is terribly contrived.
    class RobotPlugin
      include Wrack::Plugin

      receive do
        restrict :message => /robots/

        match do |msg|
          privmsg msg.sender, "DID SOMEBODY SAY ROBOTS?"
        end
      end
    end
