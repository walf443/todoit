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
          context.view.render('assets/template/layout.erb.html', {
            :title => "タスク一覧",
            :main_template => 'assets/template/task/index.erb.html',
            :tasks => tasks ,
          })
        end
      end
    end
  end
end
