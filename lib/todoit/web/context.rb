require 'rubygems'
require 'rack'
require 'classx'
require 'http_session'

module Todoit
  module Web
    class Context
      include ClassX

      has :request,
        :kind_of => Rack::Request

      has :session,
        :kind_of => HTTPSession,
        :lazy => true,
        :default => proc {|mine|
          HTTPSession.new(
            :request => mine.request,
            :state => HTTPSession::State::Cookie.new(
              :domain => mine.request.host,
              :expires => mine.now + 60 * 60 * 24,
            ),
            :store => HTTPSession::Store::Null.new,
          )
        }

      has :now,
        :kind_of => Time,
        :lazy => true,
        :default => proc {
          Time.now
        }

    end
  end
end

