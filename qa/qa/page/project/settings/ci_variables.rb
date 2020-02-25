# frozen_string_literal: true

module QA
  module Page
    module Project
      module Settings
        class CiVariables < Page::Base
          include Common

          view 'app/assets/javascripts/ci_variable_list/components/ci_variable_modal.vue' do
            element :ci_variable_key
            element :ci_variable_value
            element :ci_variable_masked
            element :save_ci_variable
          end

          view 'app/assets/javascripts/ci_variable_list/components/ci_variable_table.vue' do
            element :add_ci_variable
            element :reveal_ci_variable_value
          end

          def fill_variable(key, value, masked)
            fill_element :ci_variable_key, key
            fill_element :ci_variable_value, value
            save_ci_variable
          end

          def open_modal
            click_element :add_ci_variable
          end

          def save_ci_variable
            click_element :save_ci_variable
          end

          def reveal_variables
            click_element :reveal_ci_variable_value
          end

          def remove_variable(location: :first)
            within('.ci-variable-table .js-ci-variable-row', match: location) do
              find('.btn-danger').click
            end
          end
        end
      end
    end
  end
end
