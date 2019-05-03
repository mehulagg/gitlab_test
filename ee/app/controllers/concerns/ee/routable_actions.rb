# frozen_string_literal: true

module EE
  module RoutableActions
    extend ::Gitlab::Utils::Override

    override :perform_not_found_checks
    def perform_not_found_checks(routable, checks)
      checks += additional_checks
      super(routable, checks)
    end

    def additional_checks
      [method(:sso_check)]
    end

    def sso_check(routable)
      redirector = SsoEnforcementRedirect.new(routable)

      return unless redirector.should_process?

      if redirector.should_redirect_to_group_saml_sso?(current_user, request)
        redirect_to redirector.sso_redirect_url
      end
    end

    class SsoEnforcementRedirect
      include ::Gitlab::Routing

      attr_reader :routable

      def initialize(routable)
        @routable = routable
      end

      def routable_types
        [::Group, ::Project]
      end

      def should_process?
        routable_types.include?(routable.class)
      end

      def group
        case routable
        when ::Group
          routable
        when ::Project
          routable.group
        end
      end

      def root_group
        @root_group ||= group.root_ancestor
      end

      def sso_redirect_url
        sso_group_saml_providers_url(root_group, token: root_group.saml_discovery_token)
      end

      def should_redirect_to_group_saml_sso?(current_user, request)
        return false unless request.get?

        access_restricted_by_sso?(current_user)
      end

      def access_restricted_by_sso?(current_user)
        Ability.policy_for(current_user, routable)&.needs_new_sso_session?
      end
    end
  end
end
