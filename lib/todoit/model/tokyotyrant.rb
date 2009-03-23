require 'tokyotyrant'
require 'rubygems'
require 'classx'

module Todoit
  module Model
    # wrapper for TokyoTyrant::RDB.
    class TokyoTyrant
      include ClassX

      class ConnectionError < RuntimeError; end
      class Error < RuntimeError; end

      has :host,
        :default => "127.0.0.1"

      has :port,
        :default => 1978

      has :name_space,
        :default => 'todoit_'

      has :rdb,
        :lazy => true,
        :handles => %w[ put get mget out genuid ],
        :default => lambda {|mine|
          mine.class.connect(mine.host, mine.port)
        }

      def self.connect host, port
          tt = ::TokyoTyrant::RDBTBL.new
          tt.open(host, port) or
            raise ConnectionError, tt.errmsg

          tt
      end

      def after_init
        self.rdb # for creating connection for tokyotyrant in initaize.
      end

      %w[ out get ].each do |meth|
        define_method meth do |key|
          key = "#{self.name_space}#{key}"
          self.rdb.__send__(meth, key) or
            raise Error, self.rdb.errmsg
        end
      end

      %w[ put putkeep putcat putnr ].each do |meth|
        define_method meth do |key, val|
          key = "#{self.name_space}#{key}"
          self.rdb.__send__(meth, key, val) or
            raise Error, self.rdb.errmsg
        end
      end

      def fwmkeys prefix, max=-1
        prefix = "#{self.name_space}#{prefix}"

        result = self.rdb.fwmkeys(prefix, max)
        if result.size == 0
          raise Error, self.rdb.errmsg
        end
        result
      end

      alias get_keys fwmkeys

      def get_like prefix, max=-1
        result = get_keys(prefix, max)

        get_multi(result)
      end

      def get_multi with_prefix_keys
        hash = {}
        with_prefix_keys.each do |key|
          hash[key] = nil
        end

        raise Error, self.rdb.errmsg if self.rdb.mget(hash) < 0

        # for ruby 1.9.1
        if ''.respond_to? :force_encoding
          hash.each do |key,val|
            val.each do |k,v|
              v.force_encoding('UTF-8')
            end
          end
        end

        hash
      end

      def each &block
        self.rdb.iterinit
        while ( item = self.rdb.iternext )
          block.call(item)
        end
      end

      include Enumerable

    end
  end
end
