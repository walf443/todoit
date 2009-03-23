# vim: encoding=utf8 あいうえお
require 'time'
require 'rational'
require 'rubygems'
require 'classx'

module Todoit
  module Model
    class Task
      include ClassX
      include ClassX::Bracketable

      time_spec = {
        :kind_of => Time,
        :coerce => {
          String => proc {|val| Time.parse(val) },
        },
        :default  => proc { Time.now },
      }

      has :id,
        :optional => true

      has :title,
        :desc => "タスク名",
        :kind_of  => String,
        :validate => proc {|val| !val.nil? && val != "" }

      has :value,
        :desc => "価値",
        :kind_of => Fixnum,
        :default => 1,
        :coerce => {
          String => proc {|val| val.to_i }
        }

      has :story_point,
        :desc => "作業工数",
        :kind_of => Fixnum,
        :default => 1,
        :coerce => {
          String => proc {|val| val.to_i }
        }

      has :status,
        :desc => "状態",
        :validate => proc {|val| %w( registered done ).include? val },
        :default  => "registered",
        :coerce => {
          Symbol => proc {|val| val.to_s },
        }

      has :created_at, time_spec
      has :updated_at, time_spec

      def real_value
        Rational(self.value, self.story_point)
      end

      def to_tokyotyrant
        hash = self.to_hash
        %w( created_at updated_at ).each do |col|
          hash[col] = hash[col].strftime('%Y-%m-%d %H:%M:%S %z')
        end
        hash.delete 'id'
        hash
      end

      class << self
        ::Todoit::Utils.export self, :context

        def single id
          task = context.tokyotyrant.get("task_#{id}")
          task[:id] = id
          task.nil? ? nil : self.new(task)
        end

        def get_list option={}
          context.tokyotyrant.get_like('task').map {|key, val|
            id = key.sub("#{context.tokyotyrant.name_space}task_", '')
            val[:id] = id
            self.new(val)
          }.sort_by {|i| -1 * i.real_value }
        end

        def add hash
          id = context.tokyotyrant.genuid
          update(id, hash)
        end

        def update id, hash
          task = self.new(hash)
          task.updated_at = Time.now
          context.tokyotyrant.put("task_#{id}", task.to_tokyotyrant)
        end

      end

    end
  end
end
