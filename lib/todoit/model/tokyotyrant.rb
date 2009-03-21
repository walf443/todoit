require 'tokyotyrant'
require 'rubygems'
require 'classx'

module Todoit
  module Model
    # wrapper for TokyoTyrant::RDB.
    class TokyoTyrant
      include ClassX

      class ConnectionError < RuntimeError; end

      has :host,
        :default => "127.0.0.1"

      has :port,
        :default => 1978

      has :rdb,
        :lazy => true,
        :handles => %w[ put get mget out ],
        :default => lambda {|mine|
          tt = ::TokyoTyrant::RDB.new
          tt.open(mine.host, mine.port) or
            raise ConnectionError, tt.errmsg

          tt
        }

      def after_init
        self.rdb # for creating connection for tokyotyrant in initaize.
      end

    end
  end
end
