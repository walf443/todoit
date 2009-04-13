module Todoit
  module Model
    module Session
      class << self
        include Utils
        def select session_id
          context.tokyotyrant.get("session_#{session_id}")
        end

        def insert session_id, value
          context.tokyotyrant.put("session_#{session_id}", value)
        end

        alias update insert

        def delete session_id
          context.tokyotyrant.out("session_#{session_id}")
        end
      end
    end
  end
end
