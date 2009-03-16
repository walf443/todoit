# vim: encoding=utf-8
require 'classx'

module Todoit
  module Model
    class Task
      include ClassX
      include ClassX::Bracketable

      has :title

      class << self
        def get
          [
            { :title => "Todoitを作る" },
            { :title => "Modelを作る" },
          ].map {|i| self.new(i) }
        end
      end

    end
  end
end
