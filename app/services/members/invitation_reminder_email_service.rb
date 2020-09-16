# frozen_string_literal: true

module Members
  class InvitationReminderEmailService
    include Gitlab::Utils::StrongMemoize

    attr_reader :invitation

    def initialize(invitation)
      @invitation = invitation
    end

    def execute
      return unless experiment_enabled?

      reminder_index = days_on_which_to_send_reminders.index(days_after_invitation_sent)
      return unless reminder_index

      invitation.send_invitation_reminder(reminder_index)
    end

    private

    def experiment_enabled?
      Gitlab::Experimentation.enabled_for_attribute?(:invitation_reminders, invitation.invite_email)
    end

    def days_after_invitation_sent
      (Date.today - invitation.created_at.to_date).to_i
    end

    def days_on_which_to_send_reminders
      return [] if invitation.expires_at && invitation.expires_at <= Date.today # # Don't send any reminders if the invitation has expired or expires today

      [
        (2 * invitation_lifespan_in_days / 14.0).ceil,
        (5 * invitation_lifespan_in_days / 14.0).ceil,
        (10 * invitation_lifespan_in_days / 14.0).ceil
      ].uniq
    end

    def invitation_lifespan_in_days
      # When the invitation lifespan is more than 14 days or does not expire, send the reminders within 14 days
      strong_memoize(:invitation_lifespan_in_days) do
        if invitation.expires_at
          [(invitation.expires_at - invitation.created_at.to_date).to_i, 14].min
        else
          14
        end
      end
    end
  end
end
