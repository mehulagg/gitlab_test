# frozen_string_literal: true

class MergeTrainEntity < Grape::Entity
  include RequestAwareEntity

  expose :index
  expose :user, using: UserEntity
  expose :pipeline, using: PipelineEntity
  expose :created_at

  expose :cancel_path do |merge_train|
    cancel_train_project_merge_request_path(merge_train.project, merge_train.merge_request)
  end
end
