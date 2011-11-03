
require 'thread'

module Wrack
  class Loader

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
          preload_plugins = Wrack::Plugin.registered
          Kernel.load file
          postload_plugins = Wrack::Plugin.registered

          # Associate which plugins were loaded from the files
          @plugin_files[file] = (postload_plugins - preload_plugins)
          puts "Loaded plugins #{@plugin_files[file].join(", ")} from #{file}"
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
