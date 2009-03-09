# vim: encoding=utf-8

module Todoit
  module Web
    module C
      module Task
        extend Utils

        module_function
        def on_index
          tasks = [
            { :title => 'Todoitを作る' },
            { :title => 'Moduleの自動再読みこみ機能を作る' },
            { :title => 'Templateをコンパイルした状態でキャッシュする' },
            { :title => 'Modelを作る' },
          ]
          View::Erubis.render('assets/template/task/index.erb.html', { :tasks => tasks })
        end
      end
    end
  end
end
