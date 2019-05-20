# frozen_string_literal: true

class MergeTrainEntity < Grape::Entity
  expose :index
  expose :user, using: UserEntity
  expose :pipeline, using: PipelineDetailsEntity
  expose :created_at
end
