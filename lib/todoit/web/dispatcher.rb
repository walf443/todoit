module Todoit
  module Web
    module Dispatcher
      extend Utils

      @@cached_controller_of = {}

      def dispatch env
        path_info = request.path_info
        path_array = path_info.split('/')
        path_array.shift # ignore first slash.
        action = ( %r{/$} =~ path_info ) ? 'index' : path_array.pop
        cache_controller_key = path_array.join('/')

        # memorize right path for performance.
        unless @@cached_controller_of[cache_controller_key]
          controller = path_array.inject(Todoit::Web::C) {|init, str|
           init.const_get(str.capitalize)
          }
          if controller == Todoit::Web::C
            controller = Todoit::Web::C::Root
          end
          @@cached_controller_of[cache_controller_key] = controller
        end
        { :controller => @@cached_controller_of[cache_controller_key], :action => action }
      rescue NameError => e
        warn e
        { :controller => nil, :action => nil }
      end

      module_function :dispatch
    end
  end
end

