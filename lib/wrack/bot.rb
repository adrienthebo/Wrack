# Wrack bot implentation
#
# Implements a simple DSL to instantiate a connection to a server
# and register plugins for that connection.

require 'wrack'
require 'wrack/connection'
require 'wrack/bot/pluginmanager'

require 'wrack/plugin/logging'
require 'wrack/plugin/connection'

module Wrack
  class Bot

    attr_accessor :server, :user
    attr_accessor :manager

    def initialize(&block)
      Struct.new("Server", :server, :port, :ssl)
      Struct.new("User", :nick, :realname, :hostname, :servername, :fullname)
      @server  = Struct::Server.new
      @user    = Struct::User.new
      @klass_names = []

      configure &block if block_given?
    end

    def configure(&block)
      instance_eval &block
      self
    end

    def configure_server
      yield @server
    end

    def configure_user
      yield @user
    end

    def register(sym)
      @klass_names << sym
    end

    def run!
      @connection = Wrack::Connection.new :select_timeout => 0
      @connection.server = @server.server
      @connection.port   = @server.port

      @internal = Wrack::Bot::PluginManager.new(:connection => @connection)
      @internal.load_plugin Wrack::Plugin::Logging, self
      @internal.load_plugin Wrack::Plugin::Connection, self

      @manager = Wrack::Bot::PluginManager.new(:connection => @connection)

      load_plugins
      @connection.connect
      @connection.background!
    end

    def running?
      @connection.connected?
    end

    def unload_plugins
      @klass_names.each do |sym|
        klass = Wrack::Plugin.get_plugin sym
        @manager.unload_plugin klass
      end
    end

    def load_plugins
      @klass_names.each do |sym|
        klass = Wrack::Plugin.get_plugin sym
        @manager.load_plugin klass, self
      end
    end
  end
end

