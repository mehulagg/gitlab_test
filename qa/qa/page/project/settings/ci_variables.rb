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
            # masked_node = all_elements(:ci_variable_masked, count: keys.size + 1)[index]
            # toggle_masked(masked_node, masked)
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

          def variable_value(key)
            within('.ci-variable-table .js-ci-variable-row', text: key) do
              find('.qa-ci-variable-input-value').text
            end
          end

          def remove_variable(location: :first)
            within('.ci-variable-table .js-ci-variable-row', match: location) do
              find('.btn-danger').click
            end
          end

          private

          def toggle_masked(masked_node, masked)
            wait_until(reload: false) do
              masked_node.click

              masked ? masked_enabled?(masked_node) : masked_disabled?(masked_node)
            end
          end

          def masked_enabled?(masked_node)
            masked_node[:class].include?('is-checked')
          end

          def masked_disabled?(masked_node)
            !masked_enabled?(masked_node)
          end
        end
      end
    end
  end
end
