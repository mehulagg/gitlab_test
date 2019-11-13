# frozen_string_literal: true

module QA
  module Page
    module Project
      module Operations
        class Metrics < Page::Base
          EXPECTED_TITLE = 'Memory Usage (Total)'
          EXPECTED_LABEL = 'Total (GB)'
          LOADING_MESSAGE = 'Waiting for performance data'
          GETTING_STARTED_MESSAGE = 'Get started with performance monitoring'
          NO_DATA_MESSAGE = 'No data found'

          view 'app/assets/javascripts/monitoring/components/dashboard.vue' do
            element :prometheus_graphs
          end

          view 'app/assets/javascripts/monitoring/components/charts/time_series.vue' do
            element :prometheus_graph_widgets
          end

          view 'app/assets/javascripts/monitoring/components/panel_type.vue' do
            element :prometheus_widgets_dropdown
            element :alert_widget_menu_item
          end

          view 'ee/app/assets/javascripts/monitoring/components/alert_widget_form.vue' do
            element :alert_query_dropdown
            element :alert_query_option
            element :alert_threshold_input
          end

          def wait_for_metrics
            wait(max: 600) { has_text?(LOADING_MESSAGE) } if reload_for_metrics?

            wait(reload: false) { has_metrics? }
          end

          def reload_for_metrics?
            has_text?(GETTING_STARTED_MESSAGE) || has_text?(NO_DATA_MESSAGE)
          end

          def has_metrics?
            within_element :prometheus_graphs do
              has_text?(EXPECTED_TITLE)
            end
          end

          def wait_for_alert(operator = '>', threshold = 0)
            wait(reload: false) { has_alert?(operator, threshold) }
          end

          def has_alert?(operator = '>', threshold = 0)
            within_element :prometheus_graphs do
              has_text?([EXPECTED_LABEL, operator, threshold].join(' '))
            end
          end

          def add_alert(operator = '>', threshold = 0)
            open_alert_modal
            write_alert(operator, threshold)

            click_on 'Add'
          end

          def edit_alert(operator = '<', threshold = 0)
            open_alert_modal
            write_alert(operator, threshold)

            click_on 'Save'
          end

          def delete_alert
            open_alert_modal

            click_on 'Delete'
          end

          def write_alert(operator = '<', threshold = 0)
            click_on operator
            fill_element :alert_threshold_input, threshold
          end

          def open_alert_modal
            all_elements(:prometheus_widgets_dropdown).first.click
            click_element :alert_widget_menu_item

            click_element :alert_query_dropdown unless has_element?(:alert_query_option, wait: 3)
            all_elements(:alert_query_option).first.click
          end
        end
      end
    end
  end
end
