module EE
  module ProjectTeam
    extend ActiveSupport::Concern

    def add_users(users, access_level, current_user: nil, expires_at: nil)
      raise NotImplementedError unless defined?(super)
      return false if group_member_lock

      super
    end

    def add_user(user, access_level, current_user: nil, expires_at: nil)
      raise NotImplementedError unless defined?(super)
      return false if group_member_lock

      super
    end

    private

    def group_member_lock
      group && group.membership_lock
    end
  end
end
