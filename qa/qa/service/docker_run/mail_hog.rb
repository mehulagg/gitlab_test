# frozen_string_literal: true

module QA
  module Service
    module DockerRun
      class MailHog < Base
        def initialize
          @image = 'mailhog/mailhog:v1.0.0'
          @name = 'mailhog'

          super()
        end

        def register!
          shell <<~CMD.tr("\n", ' ')
            docker run -d --rm
            --network #{network}
            --hostname #{host_name}
            --name #{@name}
            --publish 1025:1025
            --publish 8025:8025
            #{@image}
          CMD
        end
      end
    end
  end
end
