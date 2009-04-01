require 'rubygems'
require 'haml'
require 'classx'

module Todoit
  module Web
    module View
      class Haml
        include ClassX

        class Context
          include ClassX
          include ::Haml::Helpers
          
          has :view_config
          has :params, 
            :kind_of => Hash

          def include file
            view_config.render(file, self)
          end

          def set key, value
            instance_variable_set(key, value)
          end
        end

        has :tmpl_path

        def render file, params={}
          file = File.join(self.tmpl_path, file)
          tmpl = nil
          File.open(file) do |f|
            tmpl = f.read
          end
          engine = ::Haml::Engine.new(tmpl, :filename => file, :escape_html => true)
          unless params.kind_of? Context
            params = Context.new(:view_config => self, :params => params)
          end
          engine.render(params, params.params)
        end

      end
    end
  end
end
