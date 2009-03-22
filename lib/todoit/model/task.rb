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
        }
      }

      has :id
      has :title
      has :created_at, time_spec
      has :updated_at, time_spec

      class << self
        ::Todoit::Utils.export self, :context

        def get
          tasks = []
          context.tokyotyrant.get_like('task').map {|key, val|
            id = key.sub("#{context.tokyotyrant.name_space}task_", '')
            val[:id] = id
            self.new(val)
          }.sort_by {|i| i.id }
        end

      end

    end
  end
end
