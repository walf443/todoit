module Todoit
  module Web
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
  end
end

