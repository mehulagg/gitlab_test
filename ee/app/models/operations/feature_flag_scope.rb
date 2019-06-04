# frozen_string_literal: true

module Operations
  class FeatureFlagScope < ApplicationRecord
    prepend HasEnvironmentScope

    STRATEGY_DEFAULT = 'default'.freeze
    STRATEGY_GRADUALROLLOUTUSERID = 'gradualRolloutUserId'.freeze

    self.table_name = 'operations_feature_flag_scopes'

    belongs_to :feature_flag

    validates :environment_scope, uniqueness: {
      scope: :feature_flag,
      message: "(%{value}) has already been taken"
    }

    validates :environment_scope,
      if: :default_scope?, on: :update,
      inclusion: { in: %w(*), message: 'cannot be changed from default scope' }

    validate :strategies_validations

    before_destroy :prevent_destroy_default_scope, if: :default_scope?

    scope :ordered, -> { order(:id) }
    scope :enabled, -> { where(active: true) }
    scope :disabled, -> { where(active: false) }

    delegate :name, :description, to: :feature_flag

    def self.for_unleash_clients(project:, environment:)
      feature_flag_ids = project.operations_feature_flags.pluck('id')

      where(feature_flag_id: feature_flag_ids)
        .on_environment(environment)
        .reverse
        .uniq { |scope| scope.feature_flag_id }
    end

    private

    def default_scope?
      environment_scope_was == '*'
    end

    def prevent_destroy_default_scope
      raise ActiveRecord::ReadOnlyRecord, "default scope cannot be destroyed"
    end

    def strategies_validations
      return unless strategies

      strategies.each do |strategy|
        strategy_validations(strategy)
      end
    end

    def strategy_validations(strategy)
      case strategy['name']
      when STRATEGY_DEFAULT
        default_parameters_validation(strategy)
      when STRATEGY_GRADUALROLLOUTUSERID
        gradual_rollout_user_id_parameters_validation(strategy)
      else
        errors.add(:strategies, 'strategy name is invalid')
      end
    end

    def gradual_rollout_user_id_parameters_validation(strategy)
      percentage = strategy.dig('parameters', 'percentage')
      group_id = strategy.dig('parameters', 'groupId')

      unless percentage.is_a?(String) && percentage.match(/\A[1-9]?[0-9]\z|\A100\z/)
        errors.add(:strategies, 'percentage must be a string between 0 and 100 inclusive')
      end

      unless group_id.is_a?(String) && group_id.match(/\A[a-z]{1,32}\z/)
        errors.add(:strategies, 'groupId parameter is invalid')
      end
    end

    def default_parameters_validation(strategy)
      parameters = strategy['parameters']
      unless parameters == {}
        errors.add(:strategies, 'parameters must be empty for default strategy')
      end
    end
  end
end
