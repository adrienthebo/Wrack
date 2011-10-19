# Wrack bot implentation
#
# Implements a simple DSL to instantiate a connection to a server
# and register plugins for that connection.

require 'wrack'
require 'wrack/connection'
require 'wrack/pluginmanager'

module Wrack
  class Bot

    def initialize(&block)
      Struct.new("Server", :server, :port, :ssl)
      Struct.new("User", :realname, :hostname, :servername, :fullname)
      @server  = Struct::Server.new
      @user    = Struct::User.new
      @klasses = []
      @plugins = []

      @logging = false

      configure &block if block_given?
    end

    def configure(&block)
      instance_eval &block
      self
    end

    def logging(log)
      @logging = log
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
      @connection = Wrack::Connection.new :select_timeout => 0
      @connection.server = @server.server
      @connection.port   = @server.port

      @manager = Wrack::PluginManager.new(:logging => @logging, :connection => @connection)

      reload_plugins!
      @connection.connect
      @connection.background!
    end

    def running?
      @connection.connected?
    end

    def reload_plugins!
      @plugins.each do |plugin|
        @manager.unregister_plugin plugin
        @plugins.delete plugin
      end

      # Instantiate all plugins
      @klasses.each do |klass|
        plugin = klass.new @connection

        @manager.register_plugin plugin
        @plugins << plugin
      end
    end
  end
end

