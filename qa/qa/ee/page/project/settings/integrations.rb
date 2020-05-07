# frozen_string_literal: true

module QA
  module EE
    module Page
      module Project
        module Settings
          module Integrations
            def click_jenkins_ci_link
              click_element :jenkins_link
            end
          end
        end
      end
    end
  end
end
