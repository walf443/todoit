# vim: encoding=utf-8

module Todoit
  module Web
    module C
      module Task
        extend Todoit::FunctionImporter
        import_module_function Utils, :context

        module_function
        def on_index
          tasks = Todoit::Model::Task.get
          context.view.render('assets/template/task/index.erb.html', { :tasks => tasks })
        end
      end
    end
  end
end
