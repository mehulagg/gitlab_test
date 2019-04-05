# frozen_string_literal: true

require 'securerandom'

module EE
  module Clusters
    module Applications
      module Ingress
        extend ActiveSupport::Concern

        prepended do
          state_machine :status do
            after_transition any => :updating do |application|
              application.update(last_update_started_at: Time.now)
            end
          end

          def values
            # Add EE specific values
            ce_values = YAML.load_file(chart_values_file)
            ee_values = YAML.load_file(ee_chart_values_file)
            ce_values.deep_merge(ee_values).to_yaml
          end
        end

        def ee_chart_values_file
          "#{Rails.root}/ee/vendor/#{name}/values.yaml"
        end

        def updated_since?(timestamp)
          last_update_started_at &&
            last_update_started_at > timestamp &&
            !update_errored?
        end
      end
    end
  end
end
