require 'rubygems'
require 'function_importer'

module Todoit
  module Web
    module Utils
      extend FunctionExporter

      def context
        $context
      end

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

      def around_action &block
        catch :not_found do
          catch :redirect do
            block.call
          end
        end
      end

      # it should be called with around_action.
      def not_found!
        throw :not_found, [404, { 'Content-Type' => 'text/plain', }, 'NOT FOUND' ]
      end

      # it should be called with around_action.
      def redirect! location, status=302
        throw :redirect, [status, { 'Content-Type' => 'text/plain', 'Location' => location }, 'REDIRECT' ] 
      end

      def nested_const_get nested_const, base=Object
        nested_const.split("::").inject(base) {|c, str|
          c.const_get(str)
        }
      end

    end
  end
end


