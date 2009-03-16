# vim: encoding=utf-8
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

      has :title
      has :created_at, time_spec
      has :updated_at, time_spec

      class << self
        def get
          [
            { :title => "Todoitを作る" , :created_at => '2009-03-01 10:00:00', :updated_at => '2009-03-16 22:40' },
            { :title => "Modelを作る", :created_at  => '2009-03-05 10:00:00', :updated_at => '2009-03-16 22:40' },
          ].map {|i| self.new(i) }
        end
      end

    end
  end
end
