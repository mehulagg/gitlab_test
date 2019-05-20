# frozen_string_literal: true

class MergeTrainsSummaryEntity < Grape::Entity
  expose :total_count do |merge_request|
    MergeTrain.all_in_train(merge_request).count
  end
end
