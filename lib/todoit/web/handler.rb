
module Todoit
  module Web
    class Handler
      extend Todoit::FunctionImporter
      import_function Utils, :web_context, :web_context=, :not_found

      def initialize conf={}
        @conf = conf
        raise if defined? $context
        $context = Todoit::Context.new({
          :view  => Todoit::Web::View::Erubis.new(:cache => true),
        })
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
  end
end

