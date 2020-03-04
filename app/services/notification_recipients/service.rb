# frozen_string_literal: true

#
# Used by NotificationService to determine who should receive notification
#
module NotificationRecipients
  module Service
    def self.notifiable_users(users, *args)
      users.compact.map { |u| NotificationRecipient.new(u, *args) }.select(&:notifiable?).map(&:user)
    end

    def self.notifiable?(user, *args)
      NotificationRecipient.new(user, *args).notifiable?
    end

    def self.build_recipients(*args)
      Builder::Default.new(*args).notification_recipients
    end

    def self.build_new_note_recipients(*args)
      Builder::NewNote.new(*args).notification_recipients
    end

    def self.build_merge_request_unmergeable_recipients(*args)
      Builder::MergeRequestUnmergeable.new(*args).notification_recipients
    end

    def self.build_project_maintainers_recipients(*args)
      Builder::ProjectMaintainers.new(*args).notification_recipients
    end

    def self.build_new_release_recipients(*args)
      Builder::NewRelease.new(*args).notification_recipients
    end
  end
end

NotificationRecipients::Service.prepend_if_ee('EE::NotificationRecipients::Service')
