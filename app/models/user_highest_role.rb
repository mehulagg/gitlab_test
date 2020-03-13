# frozen_string_literal: true

class UserHighestRole < ApplicationRecord
end

UserHighestRole.prepend_if_ee('EE::UserHighestRole')
