# frozen_string_literal: true

module EE
  module UsersStatistic
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override

    class_methods do
      private

      def highest_role_stats
        roles_stats = ::Member.roles_stats

        ::UsersStatistic::ROLE_VALUES.inject({}) do |attributes, role|
          attributes.merge("#{::UsersStatistic::HIGHEST_ROLE_PREFIX}#{role}".to_sym => roles_stats[role])
        end
      end
    end
  end
end
