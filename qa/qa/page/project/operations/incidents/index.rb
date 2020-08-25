# frozen_string_literal: true

module QA
  module Page
    module Project
      module Operations
        module Incidents
          class Index < Page::Base

            def create_incident
              click_link_with_text 'Create incident'
            end
          end
        end
      end
    end
  end
end
