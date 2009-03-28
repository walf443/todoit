# vim: encoding=utf-8
require 'rubygems'
require 'rack'
require 'function_importer'
require 'classx'
require 'erubis'

path = File.expand_path(File.join(File.dirname(__FILE__)))
$LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)

module Todoit
  module Model
    autoload :Task, 'todoit/model/task'
    autoload :TokyoTyrant, 'todoit/model/tokyotyrant'
  end

  autoload :Context, 'todoit/context'
  autoload :Utils, 'todoit/utils'

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

  def self.setup
    $context = Todoit::Context.new({
      :view  => Todoit::Web::View::Erubis.new(:tmpl_path => 'assets/template/'),
      :tokyotyrant => Todoit::Model::TokyoTyrant.new,
    })
  end
end

