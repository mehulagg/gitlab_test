# frozen_string_literal: true

module EE
  module QuickActions
    module CommandStore
      extend ActiveSupport::Concern

      EE_COMMAND_MODULES = [
        EE::Gitlab::QuickActions::EpicActions,
        EE::Gitlab::QuickActions::IssueActions,
        EE::Gitlab::QuickActions::MergeRequestActions,
        EE::Gitlab::QuickActions::IssueAndMergeRequestActions,
        EE::Gitlab::QuickActions::RelateActions
      ].freeze

      prepended do
        def self.command_modules
          EE_COMMAND_MODULES + ::QuickActions::CommandStore::COMMAND_MODULES
        end
      end
    end
  end
end
