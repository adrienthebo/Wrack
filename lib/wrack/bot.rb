# Wrack bot implentation
#
# Implements a simple DSL to instantiate a connection to a server
# and register plugins for that connection.

require 'wrack'
require 'wrack/connection'
require 'wrack/session'

module Wrack
  class Bot
    def initialize(&block)
      Struct.new("Server", :server, :port, :ssl)
      Struct.new("User", :realname, :hostname, :servername, :fullname)
      @server     = Struct::Server.new
      @user       = Struct::User.new
      @klasses    = []
      @plugins    = []

      configure &block if block_given?
    end

    def configure(&block)
      instance_eval &block
      self
    end

    def server
      yield @server
    end

    def user
      yield @user
    end

    def register(klass)
      @klasses << klass
    end

    def run!
      connection = Wrack::Connection.new
      connection.server = @server.server
      connection.port   = @server.port

      @session = Wrack::Session.new(:logging => true, :connection => connection)
      @session.connect

      reload_plugins!
    end

    def reload_plugins!
      # XXX Destroy all plugins

      # Instantiate all plugins
      @klasses.each do |klass|
        plugin = klass.new
        plugin.bot = self

        @plugins << plugin
      end
    end
  end
end

