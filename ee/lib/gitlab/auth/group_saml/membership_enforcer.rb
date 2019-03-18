# frozen_string_literal: true

module Gitlab
  module Auth
    module GroupSaml
      class MembershipEnforcer
        def initialize(group)
          @group = group
        end

        def can_add_user?(user)
          return true unless saml_provider&.enforced_sso?

          GroupSamlIdentityFinder.new(user: user).find_linked(group: saml_provider.group)
        end

        private

        def saml_provider
          @saml_provider ||= SamlProvider.for_group(@group)
        end
      end
    end
  end
end
