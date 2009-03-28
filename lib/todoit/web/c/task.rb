# vim: encoding=utf-8
require 'rubygems'
require 'function_importer'

module Todoit
  module Web
    module C
      module Task
        extend FunctionImporter
        import_module_function Utils, :context, :web_context, :redirect

        module_function
        def on_index
          tasks = Todoit::Model::Task.get_list
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

        def on_edit
          is_error = false
          param = web_context.request.params
          id = param['task_id'] or
            return redirect('/task/')

          task = Todoit::Model::Task.single(id) or
            return redirect('/task/')

          params = task.to_hash.merge(param)

          if web_context.request.post?
            begin
              Todoit::Model::Task.update(id, params)
              return redirect('/task/')
            rescue ClassX::InvalidAttrArgument => e
              is_error = true
            end
          end

          context.view.render('/layout.erb.html', {
            :main_template => '/task/edit.erb.html',
            :task          => params,
            :is_error      => is_error,
          })
        end

        def on_done
          return redirect('/task/') unless web_context.request.post?

          param = web_context.request.params
          id = param['task_id'] or
            return redirect('/task/')

          task = Todoit::Model::Task.single(id) or
            return redirect('/task/')

          task.status = :done
          Todoit::Model::Task.update(id, task.to_hash)

          return redirect('/task/')
        end
      end
    end
  end
end
