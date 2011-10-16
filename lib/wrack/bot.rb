# Wrack DSL
#
# Because yaml is hard, and DSLs are cheap
require 'wrack'
require 'wrack/dsl'

module Wrack
  class Bot
    def initialize(&block)
      Struct.new(Server, :server, :port, :ssl)
      Struct.new(User, :realname :hostname, :servername, :fullname)
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
      @plugins << klass
    end

    def run!
      @connection = Wrack::Connection.new
      @connection.server = @server.server
      @connection.port   = @server.port

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

        plugin << plugins
      end
    end
  end
end

