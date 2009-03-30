require 'rubygems'
require 'function_importer'

module Todoit
  module Web
    class Handler
      extend FunctionImporter
      import_function Utils, :web_context, :web_context=, :around_action, :not_found!, :nested_const_get

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

        around_action do
          unless @rule_cache_of[rule]
            begin
              controller = nested_const_get(rule[:controller], Todoit::Web::C)
            rescue NameError => e
              warn e
              not_found!
            end

            not_found! unless controller
            meth = "on_#{rule[:action]}"
            not_found! unless controller.respond_to? meth
            @rule_cache_of[rule] = { :controller => controller, :meth => meth }
          end

          rule = @rule_cache_of[rule]
          warn rule[:controller]
          rule[:controller].__send__ rule[:meth]
        end
      end

      def routing rule
      end

    end
  end
end

# FIXME: どこに書くべきか。
# 後始末
at_exit do
  $context.tokyotyrant.close
end
