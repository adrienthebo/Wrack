
require 'thread'

module Wrack
  class Loader

    def initialize
      @plugin_files = {}
      @sem = Mutex.new
    end

    def plugin_file(file)
      @plugin_files[file] = [] unless @plugin_files[file]
    end

    def load_file!(file)
      @sem.synchronize do
        begin
          preload_plugins = Wrack::Plugin.registered
          Kernel.load file
          postload_plugins = Wrack::Plugin.registered

          # Associate which plugins were loaded from the files
          @plugin_files[file] = (postload_plugins - preload_plugins)
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

    def load_all!
      @plugin_files.keys.each do |file|
        load_file! file
      end
    end
  end
end
