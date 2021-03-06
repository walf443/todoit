require 'rubygems'
require 'function_importer'

module Todoit
  module Web
    module Dispatcher
      extend FunctionImporter
      import_module_function Utils, :web_context, :request

      @@cached_controller_of = {}

      def self.dispatch env
        path_info = request.path_info
        path_array = path_info.split('/')
        path_array.shift # ignore first slash.
        action = ( %r{/$} =~ path_info ) ? 'index' : path_array.pop
        cache_controller_key = path_array.join('/')

        # memorize right path for performance.
        unless @@cached_controller_of[cache_controller_key]
          controller = path_array.map {|i| i.capitalize }.join("::")
          if controller == ""
            controller = "Root"
          end
          @@cached_controller_of[cache_controller_key] = controller
        end
        { :controller => @@cached_controller_of[cache_controller_key], :action => action }
      end
    end
  end
end

