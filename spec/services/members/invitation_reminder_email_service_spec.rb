# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Members::InvitationReminderEmailService do
  describe 'sending invitation reminders' do
    subject { described_class.new(invitation).execute }

    let(:frozen_time) { Date.today.beginning_of_day }
    let(:invitation) { build(:group_member, :invited, created_at: frozen_time, expires_at: (frozen_time + expires_at_days.days if expires_at_days)) }

    context 'when the experiment is disabled' do
      before do
        allow(Gitlab::Experimentation).to receive(:enabled_for_attribute?).and_return(false)
      end

      let(:expires_at_days) { 2 }

      it 'does not send an invitation' do
        travel_to(frozen_time + 1.day) do
          expect(invitation).not_to receive(:send_invitation_reminder)

          subject
        end
      end
    end

    context 'when the experiment is enabled' do
      before do
        allow(Gitlab::Experimentation).to receive(:enabled_for_attribute?).and_return(true)
      end

      using RSpec::Parameterized::TableSyntax

      where(:expires_at_days, :send_reminder_at_days) do
        0   | []
        1   | []
        2   | [1]
        3   | [1, 2]
        4   | [1, 2, 3]
        5   | [1, 2, 4]
        6   | [1, 3, 5]
        7   | [1, 3, 5]
        8   | [2, 3, 6]
        9   | [2, 4, 7]
        10  | [2, 4, 8]
        11  | [2, 4, 8]
        12  | [2, 5, 9]
        13  | [2, 5, 10]
        14  | [2, 5, 10]
        15  | [2, 5, 10]
        nil | [2, 5, 10]
      end

      with_them do
        # Create an invitation today with an expiration date from 0 to 15 days in the future or without an expiration date
        (0..15).each do |day|
          it 'sends an invitation reminder only on the expected days' do
            # We are traveling in a loop from today to 15 days from now
            travel_to(frozen_time + day.days) do
              # Given an expiration date and the number of days after the creation of the invitation based on the current day in the loop, a reminder may be sent
              if (reminder_index = send_reminder_at_days.index(day))
                expect(invitation).to receive(:send_invitation_reminder).with(reminder_index)
              else
                expect(invitation).not_to receive(:send_invitation_reminder)
              end

              subject
            end
          end
        end
      end
    end
  end
end
