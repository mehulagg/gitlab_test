# frozen_string_literal: true

module API
  module Entities
    class UserDetailsWithAdmin < UserWithAdmin
      expose :highest_role
      expose :current_sign_in_ip
      expose :last_sign_in_ip
      expose :plan do |user|
        #user.namespace&.plan&.name
        user.namespace.gitlab_subscription.hosted_plan.name
      end
      expose :trial do |user|
        user.namespace&.trial?
      end
    end
  end
end
