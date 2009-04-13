# vim: encoding=utf-8
require 'hpricot'
require 'erb'

module Todoit
  module Web
    # insert debug screen to last body of html.
    module Middlewares
      class DebugScreen
        def initialize app
          @app = app
        end

        def call env
          start = Time.now
          res = @app.call(env)
          delta_time = Time.now - start

          if res[0] == 200 and res[1]['Content-Type'] == 'text/html'
            result = []
            res[2].body.each do |item|
              html = Hpricot.parse(item)
              body = html.search('//body')
              body.inner_html += <<-END_OF_HTML
                <div class="debug-screen" style="background-color: #ffaaaa;">
                  <h3>Debug Screen</h3>
                  <h4>delta_time</h4>
                  <div>#{h delta_time}</div>

                  <h4>status</h4>
                  <div>#{h res[0]}</div>

                  <h4>response headers</h4>
                  <table>
                    #{
                      res[1].map {|k,v|
                        "<tr><th>#{h k}</th><td>: #{h v}</td></tr>"
                      }.join('') 
                    }
                  </table>
                </div>
              END_OF_HTML

              result.push(html.inner_html)
              res[1].delete('Content-Length') # FIXME: regenerate Content-Length
            end

            res[2] = result
          end

          return res
        end

        def h str
          ::ERB::Util.html_escape(str)
        end
      end
    end
  end
end
