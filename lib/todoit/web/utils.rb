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

      def nested_const_get nested_const, base=Object
        nested_const.split("::").inject(base) {|c, str|
          c.const_get(str)
        }
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

      # FIXME: もうちょいうまく抽象化したい感じ
      def render layout, params={}
        result = context.view.render(
          Todoit::Web::Utils.guess_tmpl_name(layout),
          { 
            :main_template => Todoit::Web::Utils.guess_tmpl_name(web_context.request.path) 
          }.merge(params)
        )
        [200, { 'Content-Type' => 'text/html' }, result ]
      end

      def self.guess_tmpl_name path
        if path =~ %r{/$}
          path += "index"
        end
        "#{path}.erb.html"
      end

      class ActionError < Exception; end
      class NotFound < ActionError; end
      class Redirect < ActionError; end

      # it should be called with around_action.

      def not_found!
        raise NotFound, [404, { 'Content-Type' => 'text/plain', }, 'NOT FOUND' ]
      end

      # it should be called with around_action.
      def redirect! location, status=302
        raise Redirect, [status, { 'Content-Type' => 'text/plain', 'Location' => location }, 'REDIRECT' ] 
      end

    end
  end
end


