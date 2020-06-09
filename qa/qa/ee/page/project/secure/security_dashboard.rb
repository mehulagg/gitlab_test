# frozen_string_literal: true

module QA
  module EE
    module Page
      module Project
        module Secure
          class SecurityDashboard < QA::Page::Base
            view 'ee/app/assets/javascripts/vulnerabilities/components/vulnerability_list.vue' do
              element :vulnerability
            end

            def has_vulnerability?(description)
              find_element(:vulnerability).has_content?(description)
            end
          end
        end
      end
    end
  end
end
