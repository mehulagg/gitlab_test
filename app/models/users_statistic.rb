# frozen_string_literal: true

class UsersStatistic < ApplicationRecord
  HIGHEST_ROLE_PREFIX = 'highest_role_is_'
  ROLE_VALUES = ::Gitlab::Access.sym_options_with_owner.values.freeze
  ROLE_STATISTICS_NAMES = ROLE_VALUES.collect {|value| "#{HIGHEST_ROLE_PREFIX}#{value}".to_sym }.freeze
  STATISTICS_NAMES = [
    :without_groups_and_projects,
    *ROLE_STATISTICS_NAMES,
    :bots,
    :blocked
  ].freeze

  validates :as_at, presence: true
end

UsersStatistic.prepend_if_ee('EE::UsersStatistic')
