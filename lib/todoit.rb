# vim: encoding=utf-8
require 'rubygems'
require 'rack'
require 'classx'
require 'erubis'

module Todoit
  module Context
    include ClassX

  end

  module Utils
    @@context = nil
    def context
      if @@context
        @@context
      else
        @@context = Context.new
      end
    end

    %w{ view }.each do |meth|
      define_method meth do
        context.__send__ meth
      end
    end
  end

  module Model
  end

  module Web
    class Context
      include ClassX

      has :request,
        :kind_of => Rack::Request

    end

    module Utils
      def web_context
        $web_context
      end

      def web_context= context
        $web_context = context
      end

      # handling via web_context method.
      %w{ request }.each do |meth|
        define_method meth do
          web_context.__send__ meth
        end
      end

      # hmm. Rack recommend this usage.
      # 
      # def web_context_init app
      #   Rack::Utils::Context.new app do |env|
      #     @@context = Web::Context.new({
      #       :request => Rack::Request.new(env)
      #     })

      #     app.call(env)
      #   end
      # end

      def not_found
        [404, { 'Content-Type' => 'text/plain', }, 'NOT FOUND' ] 
      end
    end

    module Dispatcher
      extend Utils

      @@cached_controller_of = {}

      def dispatch env
        path_info = request.path_info
        path_array = path_info.split('/')
        path_array.shift # ignore first slash.
        action = ( %r{/$} =~ path_info ) ? 'index' : path_array.pop
        cache_controller_key = path_array.join('/')
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

    class Handler
      include Utils

      def initialize conf={}
        @conf = conf
      end

      def call env
        self.web_context = Web::Context.new({
          :request => Rack::Request.new(env),
        })
        rule = Dispatcher.dispatch env
        warn rule.inspect
        meth = "on_#{rule[:action]}"
        return not_found unless rule[:controller]
        return not_found unless rule[:controller].respond_to? meth

        rule[:controller].__send__(meth)
      end
    end

    module View
      module Erubis
        def self.render file, params={}
          str = ''
          File.open file do |io|
            str = io.read
          end
          engine = ::Erubis::EscapedEruby.new(str)
          result = engine.evaluate(params)

          [200, { 'Content-Type' => 'text/html' }, result ]
        end
      end
    end

    module C
      extend Utils

      module Root
        extend Utils

        module_function

        def on_index
          require 'pp'
          pp web_context.request
          [200, { 'Content-Type' => 'text/plain', }, 'index' ]
        end

      end

      module Task
        extend Utils

        module_function
        def on_index
          tasks = [
            { :title => 'Todoitを作る' },
            { :title => 'Moduleの自動再読みこみ機能を作る' },
            { :title => 'Templateをコンパイルした状態でキャッシュする' },
            { :title => 'Modelを作る' },
          ]
          View::Erubis.render('assets/template/task/index.erb.html', { :tasks => tasks })
        end
      end

    end

  end
end
