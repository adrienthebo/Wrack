# Wrack bot implentation
#
# Implements a simple DSL to instantiate a connection to a server
# and register plugins for that connection.

require 'wrack'
require 'wrack/connection'
require 'wrack/bot/pluginmanager'

module Wrack
  class Bot

    attr_accessor :server, :user

    def initialize(&block)
      Struct.new("Server", :server, :port, :ssl)
      Struct.new("User", :nick, :realname, :hostname, :servername, :fullname)
      @server  = Struct::Server.new
      @user    = Struct::User.new
      @klasses = []

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

    def configure_server
      yield @server
    end

    def configure_user
      yield @user
    end

    def register(klass)
      @klasses << klass
    end

    def run!
      @connection = Wrack::Connection.new :select_timeout => 0
      @connection.server = @server.server
      @connection.port   = @server.port

      # TODO add internal operations plugin manager

      @manager = Wrack::Bot::PluginManager.new(:connection => @connection)

      reload_plugins!
      @connection.connect
      @connection.background!
    end

    def running?
      @connection.connected?
    end

    def reload_plugins!
      @klasses.each { |klass| @manager.unload_plugin klass }

      # Instantiate all plugins
      @klasses.each { |klass| @manager.load_plugin klass, self }
    end
  end
end

