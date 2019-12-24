# frozen_string_literal: true

module QA
  module Page
    module Project
      module Pipeline
        class New < Base
          include Page::Component::Select2

          view 'app/views/projects/pipelines/new.html.haml' do
            element :run_pipeline_button, required: true
            element :branch_dropdown, required: true
          end

          def choose_branch(branch)
            retry_on_exception do
              click_body
              click_element :branch_dropdown
              search_and_select(branch)
            end
          end

          def click_run_pipeline_button
            click_element :run_pipeline_button, Page::Project::Pipeline::Show
          end
        end
      end
    end
  end
end
