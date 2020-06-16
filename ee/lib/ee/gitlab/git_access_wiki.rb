# frozen_string_literal: true

module EE
  module Gitlab
    module GitAccessWiki
      extend ::Gitlab::Utils::Override
      include GeoGitAccess

      ERROR_MESSAGES = {
        write_to_group_wiki: "You are not allowed to write to this groups's wiki."
      }.freeze

      override :check_namespace!
      def check_namespace!
        return if group?

        super
      end

      override :check_container!
      def check_container!
        return check_group! if group?

        super
      end

      override :check_push_access!
      def check_push_access!
        return check_change_access! if container.is_a?(Group)

        super
      end

      override :write_to_wiki_message
      def write_to_wiki_message
        return ERROR_MESSAGES[:write_to_group_wiki] if group?

        super
      end

      private

      def check_group!
        not_found!(:group_not_found) unless can_read_group?
      end

      def can_read_group?
        if user
          user.can?(:read_group, container)
        else
          Guest.can?(:read_group, container)
        end
      end

      def project_or_wiki
        container.wiki
      end
    end
  end
end
