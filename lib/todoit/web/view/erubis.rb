require 'rubygems'
require 'erubis'
require 'classx'

module Todoit
  module Web
    module View
      class Erubis
        include ClassX

        def make_content file, params={}
          engine = ::Erubis::EscapedEruby.load_file(file)
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

