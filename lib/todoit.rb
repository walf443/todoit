# vim: encoding=utf-8
require 'rubygems'
require 'rack'
require 'classx'
require 'erubis'

path = File.expand_path(File.join(File.dirname(__FILE__)))
$LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)

module Todoit
  module Context
    include ClassX

  end

  module Utils
    @@context = nil
    def context
      if @@context
        @@context
      else
        @@context = Context.new
      end
    end

    %w{ view }.each do |meth|
      define_method meth do
        context.__send__ meth
      end
    end
  end

  module Model
  end

  module Web
    autoload :Context,    'todoit/web/context'
    autoload :Utils,      'todoit/web/utils'
    autoload :Handler,    'todoit/web/handler'
    autoload :Dispatcher, 'todoit/web/dispatcher'

    module View
      autoload :Erubis,   'todoit/web/view/erubis'
    end

    module C
      autoload :Root, 'todoit/web/c/root'
      autoload :Task, 'todoit/web/c/task'
    end

  end
end
