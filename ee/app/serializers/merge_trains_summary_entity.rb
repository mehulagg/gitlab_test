# frozen_string_literal: true

class MergeTrainsSummaryEntity < Grape::Entity
  include RequestAwareEntity

  expose :total_count do |merge_request|
    MergeTrain.all_in_train(merge_request).count
  end

  expose :create_path do |merge_request|
    create_train_project_merge_request_path(merge_request.project, merge_request)
  end
end
