# frozen_string_literal: true

# rubocop:disable Gitlab/ModuleWithInstanceVariables
module EE
  module Admin
    module DashboardController
      extend ActiveSupport::Concern
      extend ::Gitlab::Utils::Override

      LICENSE_BREAKDOWN_USER_LIMIT = 100_000

      override :index
      def index
        super

        @license = License.current
      end

      def stats
        @counts = {
          admin: ::User.admins.count,
          without_groups_and_projects: ::User.without_projects.without_groups.humans.count,
          roles: ::ProjectAuthorization.roles_stats,
          active: ::User.active.count,
          blocked: ::User.blocked.count,
          total: ::User.count
        }
      end

      # The license section may time out if the number of users is
      # high. To avoid 500 errors, just hide this section. This is a
      # workaround for https://gitlab.com/gitlab-org/gitlab/issues/32287.
      override :show_license_breakdown?
      def show_license_breakdown?
        return false unless @counts.is_a?(Hash)

        @counts.fetch(::User, 0) < LICENSE_BREAKDOWN_USER_LIMIT
      end
    end
  end
end
