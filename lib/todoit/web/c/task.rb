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
          is_error = false
          if web_context.request.post?
            begin
              Todoit::Model::Task.add(web_context.request.params)
              return redirect('/task/')
            rescue ClassX::InvalidAttrArgument => e
              is_error = true
            end
          end
          context.view.render('/layout.erb.html', {
            :main_template => '/task/add.erb.html',
            :is_error      => is_error,
          })
        end
      end
    end
  end
end
