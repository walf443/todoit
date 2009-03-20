require 'rubygems'
require 'erubis'
require 'classx'

module Todoit
  module Web
    module View
      class Erubis
        include ClassX

        has :cache,
          :optional => true,
          :default  => true

        def after_init
          @precompile_cache_of = {}
        end

        def make_content file, params={}
          if self.cache && @precompile_cache_of[file]
          else
            str = ''
            File.open file do |io|
              str = io.read
            end
            engine = ::Erubis::EscapedEruby.new(str)
            @precompile_cache_of[file] = engine
          end

          @precompile_cache_of[file].evaluate(params)
        end

        def render file, params={}
          result = make_content file, params
          [200, { 'Content-Type' => 'text/html' }, result ]
        end
      end
    end
  end
end

