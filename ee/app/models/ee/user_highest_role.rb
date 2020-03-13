# frozen_string_literal: true

module EE
  module UserHighestRole
    extend ActiveSupport::Concern

    prepended do
      belongs_to :user, optional: false

      validates :highest_access_level, allow_nil: true, inclusion: { in: ::Gitlab::Access.all_values }
    end
  end
end
