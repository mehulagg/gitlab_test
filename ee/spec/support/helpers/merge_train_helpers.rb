# frozen_string_literal: true

module MergeTrainHelpers
  def enable_merge_train(project)
    stub_feature_flags(disable_merge_trains: false)
    stub_licensed_features(merge_pipelines: true, merge_trains: true)
    project.update(merge_pipelines_enabled: true)
  end
end
