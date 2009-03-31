require 'rubygems'
require 'function_importer'

module Todoit
  module Web
    class Handler
      extend FunctionImporter
      import_function Utils, :web_context, :web_context=, :not_found!, :nested_const_get

      def initialize conf={}
        @conf = conf
        @env = conf[:env] || "product"
        raise "context already defined!! : #{ $context.inspect }" if defined? $context
        Todoit.setup
        @rule_cache_of = {}
      end

      def call env
        self.web_context = Web::Context.new({
          :request => Rack::Request.new(env),
        })

        rule = Dispatcher.dispatch env

        unless @rule_cache_of[rule]
          @rule_cache_of[rule] = routing rule
        end

        rule = @rule_cache_of[rule]
        rule[:controller].__send__ rule[:meth]
      rescue Utils::ActionError => e
        e.message
      end

      def routing rule
        begin
          controller = nested_const_get(rule[:controller], Todoit::Web::C)
        rescue NameError => e
          not_found!
        end

        not_found! unless controller
        meth = "on_#{rule[:action]}"
        not_found! unless controller.respond_to? meth

        { :controller => controller, :meth => meth }
      end

    end
  end
end

# FIXME: どこに書くべきか。
# 後始末
at_exit do
  $context.tokyotyrant.close
end
