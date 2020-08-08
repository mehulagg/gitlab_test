# frozen_string_literal: true

module Git
  class TagPushService < ::BaseService
    include ChangeParams

    def execute
      return unless Gitlab::Git.tag_ref?(ref)

      project.repository.before_push_tag
      TagHooksService.new(project, current_user, params).execute

      event = Git::TagPushedEvent.new(data: { project_id: project.id, user_id: current_user.id, params: params })
      Gitlab::EventStore.publish(event)

      true
    end
  end
end
