require 'rubygems'
require 'erubis'

module Todoit
  module Web
    module View
      class Erubis
        def initialize
          @precompile_cache_of = {};
        end

        def render file, params={}
          if @precompile_cache_of[file]
          else
            str = ''
            File.open file do |io|
              str = io.read
            end
            engine = ::Erubis::EscapedEruby.new(str)
            @precompile_cache_of[file] = engine
          end
          result = @precompile_cache_of[file].evaluate(params)

          [200, { 'Content-Type' => 'text/html' }, result ]
        end
      end
    end
  end
end

