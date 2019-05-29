# frozen_string_literal: true

module Gitlab
  module Ci
    class Config
      module Required
        class Processor
          RequiredError = Class.new(StandardError)

          def initialize(config)
            @config = config
          end

          def perform
            return @config unless ::License.feature_available?(:required_template_inclusion)
            return @config unless required_template_name

            merge_required_template!
          end

          def merge_required_template!
            raise RequiredError, 'Required template not found!' unless required_template

            @config.deep_merge!(required_template)
          end

          private

          def required_template
            ::YAML.safe_load(File.read(required_template_path))
          end

          def required_template_path
            ::TemplateFinder.build(:gitlab_ci_ymls, nil, name: required_template_name).execute
          end

          def required_template_name
            ::Gitlab::CurrentSettings.current_application_settings.required_template_name
          end
        end
      end
    end
  end
end
