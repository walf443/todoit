module Todoit
  module Web
    module C
      module User
        extend FunctionImporter
        import_module_function Utils, :context, :web_context, :redirect!, :render

        module_function

        def on_index
        end

        def on_add
          is_error = false
          if web_context.request.post?
            begin
            rescue ClassX::InvalidAttrArgument => e
              is_error = true
            end
          end
          render(:layout, {
            :is_error      => is_error,
          })
        end

        def on_edit
        end

        def on_delete
        end
      end
    end
  end
end
