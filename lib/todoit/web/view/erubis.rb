require 'rubygems'
require 'erubis'

module Todoit
  module Web
    module View
      class Erubis

        class Context < ::Erubis::Context
          def include file
            engine = ::Erubis::EscapedEruby.load_file(file)
            engine.evaluate(self)
          end
        end

        def make_content file, params={}
          engine = ::Erubis::EscapedEruby.load_file(file)
          unless params.kind_of? Context
            params = Context.new(params)
          end
          engine.evaluate(params)
        end

        def render file, params={}
          result = make_content file, params
          [200, { 'Content-Type' => 'text/html' }, result ]
        end
      end
    end
  end
end

