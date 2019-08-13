# frozen_string_literal: true

module API
  module Support
    class Actor
      attr_reader :obj, :type

      def initialize(obj, type)
        @obj = obj
        @type = (type || 'Key').underscore
      end

      # rubocop: disable CodeReuse/ActiveRecord
      def self.from_params(params)
        if params[:key_id]
          key = Key.find_by(id: params[:key_id])
          new(key, key.type || 'key')
        elsif params[:user_id]
          new(User.find_by(id: params[:user_id]), 'user_via_user_id')
        elsif params[:username]
          new(UserFinder.new(params[:username]).find_by_username, 'user_via_username')
        end
      end
      # rubocop: enable CodeReuse/ActiveRecord

      def user
        obj.is_a?(Key) ? obj.user : obj
      end

      def username
        user&.username
      end

      def update_last_used_at!
        obj.update_last_used_at if obj.is_a?(Key)
      end
    end
  end
end
