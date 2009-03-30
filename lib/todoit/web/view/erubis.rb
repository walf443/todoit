require 'rubygems'
require 'erubis'
require 'classx'

module Todoit
  module Web
    module View
      class Erubis
        include ClassX

        class Context < ::Erubis::Context
          def include file
            @view_config.render(file, self)
          end
        end

        has :tmpl_path

        def render file, params={}
          engine = ::Erubis::EscapedEruby.load_file(File.join(self.tmpl_path, file))
          unless params.kind_of? Context
            params = Context.new(params)
          end
          params[:view_config] = self
          engine.evaluate(params)
        end
      end
    end
  end
end

