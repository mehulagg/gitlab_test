# frozen_string_literal: true

class UsersStatistic < ApplicationRecord
  ROLE_STATISTICS_NAMES = ::Gitlab::Access.sym_options_with_owner.values.collect {|value| "highest_role_is_#{value}".to_sym }
  STATISTICS_NAMES = [
    :without_groups_and_projects,
    *ROLE_STATISTICS_NAMES,
    :bots,
    :blocked
  ].freeze

  validates :as_at, presence: true
end
