# vim: encoding=utf-8

module Todoit
  module Web
    module C
      module Task
        extend Todoit::FunctionImporter
        import_module_function Utils, :context, :redirect

        module_function
        def on_index
          tasks = Todoit::Model::Task.get
          context.view.render('/layout.erb.html', {
            :main_template => '/task/index.erb.html',
            :tasks => tasks ,
          })
        end

        def on_add
          if web_context.request.post?
            Todoit::Model::Task.add(web_context.request.params)
            return redirect('/task/')
          end
          context.view.render('/layout.erb.html', {
            :main_template => '/task/add.erb.html',
          })
        end
      end
    end
  end
end
