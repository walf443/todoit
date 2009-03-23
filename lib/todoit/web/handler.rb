
module Todoit
  module Web
    class Handler
      extend Todoit::FunctionImporter
      import_function Utils, :web_context, :web_context=, :not_found, :nested_const_get

      def initialize conf={}
        @conf = conf
        @env = conf[:env] || "product"
        raise "context already defined!! : #{ $context.inspect }" if defined? $context
        $context = Todoit::Context.new({
          :view  => Todoit::Web::View::Erubis.new(:tmpl_path => 'assets/template/'),
          :tokyotyrant => Todoit::Model::TokyoTyrant.new,
        })
        @rule_cache_of = {}
      end

      def call env
        self.web_context = Web::Context.new({
          :request => Rack::Request.new(env),
        })
        rule = Dispatcher.dispatch env
        unless @rule_cache_of[rule]
          begin
            controller = nested_const_get(rule[:controller], Todoit::Web::C)
          rescue NameError => e
            return not_found
          end
          return not_found unless controller
          meth = "on_#{rule[:action]}"
          return not_found unless controller.respond_to? meth
          @rule_cache_of[rule] = { :controller => controller, :meth => meth }
        end

        rule = @rule_cache_of[rule]
        rule[:controller].__send__ rule[:meth]
      end
    end
  end
end

# FIXME: どこに書くべきか。
# 後始末
at_exit do
  $context.tokyotyrant.close
end
