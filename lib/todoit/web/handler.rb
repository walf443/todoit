
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
        })
      end

      def call env
        self.web_context = Web::Context.new({
          :request => Rack::Request.new(env),
        })
        rule = Dispatcher.dispatch env
        warn rule.inspect
        meth = "on_#{rule[:action]}"
        begin
          controller = nested_const_get(rule[:controller], Todoit::Web::C)
        rescue NameError => e
          return not_found
        end
        return not_found unless controller
        return not_found unless controller.respond_to? meth

        controller.__send__(meth)
      end
    end
  end
end

