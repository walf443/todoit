# vim: encoding=utf8 あいうえお
require 'time'
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
        :kind_of  => String,
        :validate => proc {|val| !val.nil? && val != "" }

      has :created_at, time_spec
      has :updated_at, time_spec

      def to_tokyotyrant
        hash = self.to_hash
        %w( created_at updated_at ).each do |col|
          hash[col] = hash[col].strftime('%Y-%m-%d %H:%M:%S %z')
        end
        hash
      end

      class << self
        ::Todoit::Utils.export self, :context

        def single id
          task = context.tokyotyrant.get("task_#{id}")
          task.nil? ? nil : self.new(task)
        end

        def get_list option={}
          context.tokyotyrant.get_like('task').map {|key, val|
            id = key.sub("#{context.tokyotyrant.name_space}task_", '')
            val[:id] = id
            self.new(val)
          }.sort_by {|i| i.id }
        end

        def add hash
          task = self.new(hash)
          task.id = context.tokyotyrant.genuid
          context.tokyotyrant.put("task_#{task.id}", task.to_tokyotyrant)
        end

      end

    end
  end
end
