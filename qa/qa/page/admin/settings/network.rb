# frozen_string_literal: true

module QA
  module Page
    module Admin
      module Settings
        class Network < Page::Base
          include QA::Page::Settings::Common

          view 'app/views/admin/application_settings/network.html.haml' do
            element :ip_limits_section
            element :performance_optimization_section
          end

          view 'app/views/admin/application_settings/_performance.html.haml' do
            element :authorized_keys_enabled_checkbox
            element :save_changes_button
          end

          def expand_ip_limits(&block)
            expand_section(:ip_limits_section) do
              Component::IpLimits.perform(&block)
            end
          end

          def disable_write_to_authorized_keys
            expand_section(:performance_optimization_section) do
              uncheck_element(:authorized_keys_enabled_checkbox)
              click_element(:save_changes_button)
            end
          end

        end
      end
    end
  end
end
