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

      StorageType = ::TokyoTyrant::RDBTBL

      has :host,
        :default => "127.0.0.1"

      has :port,
        :default => 1978

      has :name_space,
        :default => 'todoit_'

      has :rdb,
        :lazy => true,
        :handles => %w[ genuid ],
        :default => lambda {|mine|
          mine.class.connect(mine.host, mine.port)
        }

      def self.connect host, port
          tt = StorageType.new
          tt.open(host, port) or
            raise ConnectionError, tt.errmsg

          tt
      end

      def close
        self.rdb.close
        self.rdb = nil
      end

      def reconnect
        self.close
        self.rdb = self.class.connect(self.host, self.port)
      end

      def after_init
        self.rdb # for creating connection for tokyotyrant in initaize.
      end

      %w[ out get ].each do |meth|
        define_method meth do |key|
          begin
            key = "#{self.name_space}#{key}"
            result = self.rdb.__send__(meth, key) or
              raise_exeption(self.rdb.ecode)

            # for ruby 1.9.1
            if !result.nil? and ''.respond_to? :force_encoding
              result.each do |k,v|
                v.force_encoding('UTF-8')
              end
            end
            result
          rescue ConnectionError => e
            reconnect
            retry
          end
        end
      end

      %w[ put putkeep putcat putnr ].each do |meth|
        define_method meth do |key, val|
          begin
            key = "#{self.name_space}#{key}"
            self.rdb.__send__(meth, key, val) or
              raise_exeption(self.rdb.ecode)
          rescue ConnectionError => e
            reconnect
            retry
          end
        end
      end

      def fwmkeys prefix, max=-1
        prefix = "#{self.name_space}#{prefix}"

        result = self.rdb.fwmkeys(prefix, max)
        if result.size == 0
          raise_exeption(self.rdb.ecode)
        end
        result
      rescue ConnectionError => e
        reconnect
        retry
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

        raise_exeption(self.rdb.ecode) if self.rdb.mget(hash) < 0

        # for ruby 1.9.1
        if ''.respond_to? :force_encoding
          hash.each do |key,val|
            val.each do |k,v|
              v.force_encoding('UTF-8')
            end
          end
        end

        hash
      rescue ConnectionError => e
        reconnect
        retry
      end

      def raise_exeption ecode
        case ecode
        when StorageType::EKEEP, StorageType::ENOREC, StorageType::EMISC, StorageType::ESUCCESS
          # pass
        when StorageType::EREFUSED, 
            StorageType::ESEND,
            StorageType::ERECV
          raise ConnectionError, self.rdb.errmsg
        when StorageType::EINVALID, StorageType::ENOHOST
          raise "some thing wrong: #{self.rdb.inspect}"
        else
          raise "unknown ecode: #{ecode}"

        end
      end
    end
  end
end
