require 'rubygems'
require 'function_importer'

module Todoit
  module Web
    module C
      module Root
        extend FunctionImporter
        import_module_function Utils, :web_context

        module_function

        def on_index
          require 'pp'
          pp web_context.request
          [200, { 'Content-Type' => 'text/plain', }, 'index' ]
        end
      end
    end
  end
end
