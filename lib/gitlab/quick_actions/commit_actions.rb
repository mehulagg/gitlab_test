# frozen_string_literal: true

module Gitlab
  module QuickActions
    module CommitActions
      include Gitlab::QuickActions::DslNew

      types Commit

      command :tag do
        # Commit only quick actions definitions
        desc _('Tag this commit.')
        params 'v1.2.3 <message>'
        explanation do |tag_name, message|
          if message.present?
            _("Tags this commit to %{tag_name} with \"%{message}\".") % { tag_name: tag_name, message: message }
          else
            _("Tags this commit to %{tag_name}.") % { tag_name: tag_name }
          end
        end
        execution_message do |tag_name, message|
          if message.present?
            _("Tagged this commit to %{tag_name} with \"%{message}\".") % { tag_name: tag_name, message: message }
          else
            _("Tagged this commit to %{tag_name}.") % { tag_name: tag_name }
          end
        end
        parse_params do |tag_name_and_message|
          tag_name_and_message.split(' ', 2)
        end
        condition do
          current_user.can?(:push_code, project)
        end
        action do |tag_name, message|
          update(tag_name: tag_name, tag_message: message)
        end
      end
    end
  end
end
