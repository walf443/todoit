require 'rubygems'
require 'erubis'

module Todoit
  module Web
    module View
      class Erubis
        include ClassX

        class Context < ::Erubis::Context
          def include file
            engine = ::Erubis::EscapedEruby.load_file(File.join(@view_config.tmpl_path, file))
            engine.evaluate(self)
          end
        end

        has :tmpl_path

        def make_content file, params={}
          engine = ::Erubis::EscapedEruby.load_file(File.join(self.tmpl_path, file))
          unless params.kind_of? Context
            params = Context.new(params)
          end
          params[:view_config] = self
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

