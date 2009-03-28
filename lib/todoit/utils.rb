require 'rubygems'
require 'function_importer'

module Todoit
  module Utils
    extend FunctionExporter

    def context
      $context
    end
  end
end

