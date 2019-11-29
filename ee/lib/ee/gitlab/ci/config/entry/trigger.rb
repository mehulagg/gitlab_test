# frozen_string_literal: true

module EE
  module Gitlab
    module Ci
      module Config
        module Entry
          ##
          # Entry that represents a cross-project downstream trigger.
          #
          class Trigger < ::Gitlab::Config::Entry::Simplifiable
            strategy :SimpleTrigger, if: -> (config) { config.is_a?(String) }
            strategy :ComplexTrigger, if: -> (config) { config.is_a?(Hash) }

            class SimpleTrigger < ::Gitlab::Config::Entry::Node
              include ::Gitlab::Config::Entry::Validatable

              validations { validates :config, presence: true }

              def value
                { project: @config }
              end
            end

            class ComplexTrigger < ::Gitlab::Config::Entry::Node
              include ::Gitlab::Config::Entry::Configurable
              include ::Gitlab::Config::Entry::Validatable
              include ::Gitlab::Config::Entry::Attributable

              ALLOWED_KEYS = %i[project branch strategy include].freeze
              attributes :project, :branch, :strategy

              validations do
                validates :config, presence: true
                validates :config, allowed_keys: ALLOWED_KEYS
                validates :project, presence: true, unless: :child_pipeline?
                validates :branch, type: String, allow_nil: true
                validates :strategy, type: String, inclusion: { in: %w[depend], message: 'should be depend' }, allow_nil: true

                validate do
                  if child_pipeline? && project.present?
                    errors.add(:config, 'should not contain project when include is used')
                  end

                  if child_pipeline? && branch.present?
                    errors.add(:config, 'should not contain branch when include is used')
                  end

                  if value.key?(:include) && !child_pipeline?
                    errors.add(:include, 'keyword is not allowed')
                  end
                end
              end

              entry :include, ::Gitlab::Ci::Config::Entry::Includes,
                description: 'List of external YAML files to include.',
                reserved: true

              def child_pipeline?
                ::Feature.enabled?(:ci_parent_child_pipelines) && @config.key?(:include)
              end

              def value
                @config
              end
            end

            class UnknownStrategy < ::Gitlab::Config::Entry::Node
              def errors
                ["#{location} has to be either a string or a hash"]
              end
            end
          end
        end
      end
    end
  end
end
