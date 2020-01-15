# frozen_string_literal: true

module EE
  module Gitlab
    module Analytics
      module ValueStreamAnalytics
        module StageEvents
          extend ActiveSupport::Concern

          prepended do
            extend ::Gitlab::Utils::StrongMemoize
          end

          EE_ENUM_MAPPING = {
            ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::IssueClosed => 3,
            ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::IssueFirstAddedToBoard => 4,
            ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::IssueFirstAssociatedWithMilestone => 5,
            ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::IssueFirstMentionedInCommit => 6,
            ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::IssueLastEdited => 7,
            ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::IssueLabelAdded => 8,
            ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::IssueLabelRemoved => 9,
            ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::MergeRequestClosed => 105,
            ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::MergeRequestLastEdited => 106,
            ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::MergeRequestLabelAdded => 107,
            ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::MergeRequestLabelRemoved => 108
          }.freeze

          EE_EVENTS = EE_ENUM_MAPPING.keys.freeze

          EE_PAIRING_RULES = {
            ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::IssueLabelAdded => [
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::IssueLabelAdded,
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::IssueLabelRemoved,
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::IssueClosed
            ],
            ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::IssueLabelRemoved => [
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::IssueClosed
            ],
            ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::IssueCreated => [
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::IssueClosed,
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::IssueFirstAddedToBoard,
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::IssueFirstAssociatedWithMilestone,
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::IssueFirstMentionedInCommit,
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::IssueLastEdited,
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::IssueLabelAdded,
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::IssueLabelRemoved
            ],
            ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::IssueFirstAddedToBoard => [
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::IssueClosed,
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::IssueFirstAssociatedWithMilestone,
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::IssueFirstMentionedInCommit,
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::IssueLastEdited,
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::IssueLabelAdded,
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::IssueLabelRemoved
            ],
            ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::IssueFirstAssociatedWithMilestone => [
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::IssueClosed,
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::IssueFirstAddedToBoard,
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::IssueFirstMentionedInCommit,
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::IssueLastEdited,
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::IssueLabelAdded,
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::IssueLabelRemoved
            ],
            ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::IssueFirstMentionedInCommit => [
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::IssueClosed,
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::IssueFirstAssociatedWithMilestone,
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::IssueFirstAddedToBoard,
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::IssueLastEdited,
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::IssueLabelAdded,
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::IssueLabelRemoved
            ],
            ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::IssueClosed => [
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::IssueLastEdited,
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::IssueLabelAdded,
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::IssueLabelRemoved
            ],
            ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::MergeRequestCreated => [
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::MergeRequestClosed,
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::MergeRequestFirstDeployedToProduction,
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::MergeRequestLastBuildStarted,
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::MergeRequestLastBuildFinished,
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::MergeRequestLastEdited,
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::MergeRequestLabelAdded,
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::MergeRequestLabelRemoved
            ],
            ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::MergeRequestClosed => [
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::MergeRequestFirstDeployedToProduction,
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::MergeRequestLastEdited,
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::MergeRequestLabelAdded,
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::MergeRequestLabelRemoved
            ],
            ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::MergeRequestFirstDeployedToProduction => [
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::MergeRequestLastEdited,
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::MergeRequestLabelAdded,
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::MergeRequestLabelRemoved
            ],
            ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::MergeRequestLastBuildStarted => [
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::MergeRequestClosed,
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::MergeRequestFirstDeployedToProduction,
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::MergeRequestLastEdited,
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::MergeRequestMerged,
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::MergeRequestLabelAdded,
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::MergeRequestLabelRemoved
            ],
            ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::MergeRequestLastBuildFinished => [
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::MergeRequestClosed,
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::MergeRequestFirstDeployedToProduction,
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::MergeRequestLastEdited,
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::MergeRequestMerged,
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::MergeRequestLabelAdded,
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::MergeRequestLabelRemoved
            ],
            ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::MergeRequestMerged => [
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::MergeRequestClosed,
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::MergeRequestFirstDeployedToProduction,
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::MergeRequestLastEdited,
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::MergeRequestLabelAdded,
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::MergeRequestLabelRemoved
            ],
            ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::MergeRequestLabelAdded => [
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::MergeRequestLabelAdded,
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::MergeRequestLabelRemoved
            ],
            ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::MergeRequestLabelRemoved => [
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::MergeRequestLabelAdded,
              ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::MergeRequestLabelRemoved
            ]
          }.freeze

          class_methods do
            extend ::Gitlab::Utils::Override

            override :events
            def events
              strong_memoize(:events) do
                super + EE_EVENTS
              end
            end

            override :pairing_rules
            def pairing_rules
              strong_memoize(:pairing_rules) do
                # merging two hashes with array values
                ::Gitlab::Analytics::ValueStreamAnalytics::StageEvents::PAIRING_RULES.merge(EE_PAIRING_RULES) do |klass, foss_events, ee_events|
                  foss_events + ee_events
                end
              end
            end

            override :enum_mapping
            def enum_mapping
              strong_memoize(:enum_mapping) do
                super.merge(EE_ENUM_MAPPING)
              end
            end
          end
        end
      end
    end
  end
end
