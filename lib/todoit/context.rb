require 'rubygems'
require 'classx'

module Todoit
  class Context
    include ClassX

    has :view, 
      :respond_to => :render

    has :tokyotyrant
  end
end
