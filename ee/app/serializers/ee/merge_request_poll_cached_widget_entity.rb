# frozen_string_literal: true

module EE
  module MergeRequestPollCachedWidgetEntity
    extend ActiveSupport::Concern

    prepended do
      expose :merge_train_when_pipeline_succeeds_docs_path do |merge_request|
        presenter(merge_request).merge_train_when_pipeline_succeeds_docs_path
      end

      expose :policy_violation do |merge_request|
        presenter(merge_request).has_denied_policies?
      end
    end
  end
end
