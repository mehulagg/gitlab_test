# frozen_string_literal: true

##
# We override the existing userWithId strategy to make it compatible with ActiveRecord
# objects such as Project, Group, User, etc.
#
# To properly gate a feature per target, you have to define userWithId strategy
# params in the following convention.
#
# "<The class name of the object>:<id of the row>"
#
# For example, if you want to enable a featue on the project (id: 123), you need
# to define the value "Project:123".
module Unleash
  module Strategy
    class UserWithId < Base
      def name
        'userWithId'
      end

      # requires: params['userIds'], context.user_id,
      def is_enabled?(params = {}, context = nil)
        return false unless params.is_a?(Hash) && params.has_key?(PARAM)
        return false unless params.fetch(PARAM, nil).is_a? String
        return false unless context.class.name == 'Unleash::Context'

        target = context.properties[:thing]

        params[PARAM].split(",").map(&:strip).any? { |allowed| allowed == target }
      end
    end
  end
end
