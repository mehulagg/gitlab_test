# frozen_string_literal: true

class MemberInvitationReminderEmailsWorker # rubocop:disable Scalability/IdempotentWorker
  include ApplicationWorker
  include CronjobQueue # rubocop:disable Scalability/CronWorkerContext

  feature_category :subgroups
  urgency :low

  def perform
    return unless Gitlab::Experimentation.enabled?(:invitation_reminders)

    # To keep this MR small, implementation will be done in another MR
  end
end
