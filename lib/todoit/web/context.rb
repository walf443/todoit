require 'rubygems'
require 'rack'
require 'classx'

module Todoit
  module Web
    class Context
      include ClassX

      has :request,
        :kind_of => Rack::Request

    end
  end
end

