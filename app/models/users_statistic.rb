# frozen_string_literal: true

class UsersStatistic < ApplicationRecord
  HIGHEST_ROLE_PREFIX = 'with_highest_role_'.freeze
  ROLE_NAMES = ::Gitlab::Access.sym_options_with_owner.keys.freeze
  ROLE_STATISTICS_NAMES = ROLE_NAMES.collect {|role| "#{HIGHEST_ROLE_PREFIX}#{role}".to_sym }.freeze
  STATISTICS_NAMES = [
    :without_groups_and_projects,
    *ROLE_STATISTICS_NAMES,
    :bots,
    :blocked
  ].freeze

  validates :captured_at, presence: true
end
