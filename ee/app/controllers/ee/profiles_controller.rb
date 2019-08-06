# frozen_string_literal: true

module EE
  module ProfilesController
    extend ::Gitlab::Utils::Override

    override :user_params_attributes
    def user_params_attributes
      super + user_params_attributes_ee
    end

    def user_params_attributes_ee
      %i[snowplow_tracking]
    end
  end
end
