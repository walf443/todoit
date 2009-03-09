require 'rubygems'
require 'erubis'

module Todoit
  module Web
    module View
      module Erubis
        def self.render file, params={}
          str = ''
          File.open file do |io|
            str = io.read
          end
          engine = ::Erubis::EscapedEruby.new(str)
          result = engine.evaluate(params)

          [200, { 'Content-Type' => 'text/html' }, result ]
        end
      end
    end
  end
end

