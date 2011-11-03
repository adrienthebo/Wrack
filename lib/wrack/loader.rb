
require 'thread'

module Wrack
  class PluginLoader

    def initialize
      @plugin_files = Hash.new(Array.new)
      @sem = Mutex.new
    end

    def addplugin(plugin_file)
      @plugin_files[plugin_file] = [] unless @plugin_files[plugin_file]
    end

    def load_file!(file)
      @sem.synchronize do
        begin
          $stderr.puts "Loading file #{file}"
          Kernel.load file
        rescue => e
          $stderr.puts "Error while loading plugin file #{file}: #{e}"
          $stderr.puts e.backtrace
        end
      end
    end

    def unload_file!(file)
      constants = @plugin_files[file]

      constants.each do |const|
        Object.send(:remove_const, const.name.intern)
      end
    end

    def reload_known_plugins!
      @plugin_files.keys.each do |plugin|
        unload_file! plugin
        load_file!   plugin
      end
    end
  end
end
