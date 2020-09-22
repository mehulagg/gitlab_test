# frozen_string_literal: true

module API
  module Entities
    class UserWithAdmin < UserPublic
      expose :admin?, as: :is_admin
      expose :note
      expose :using_license_seat?, as: :using_license_seat
    end
  end
end
