# frozen_string_literal: true

class UserForMergeRequestEntity < UserEntity
  expose :can_merge do |user, options|
    options[:merge_request].can_be_merged_by?(user)
  end
end
