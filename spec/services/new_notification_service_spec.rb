# frozen_string_literal: true

require "spec_helper"

describe NotificationService, :mailer do
  include EmailSpec::Matchers
  include ExternalAuthorizationServiceHelpers
  include NotificationHelpers

  let(:user) { build(:user, id: 1) }
  let(:notification) { described_class.new }

  before do
    allow(user).to receive(:can?).with(:receive_notifications) { true }

    # ActiveJob needs this
    allow(User).to receive(:find).with("1") { user }

    reset_delivered_emails!
  end

  describe "#async" do
    let(:async) { notification.async }
    let(:key) { double(:personal_key) }

    it "returns an Async object with the correct parent" do
      expect(async).to be_a(described_class::Async)
      expect(async.parent).to eq(notification)
    end

    context "when receiving a public method" do
      it "schedules a MailScheduler::NotificationServiceWorker" do
        expect(MailScheduler::NotificationServiceWorker)
          .to receive(:perform_async).with("new_key", key)

        async.new_key(key)
      end
    end

    context "when receiving a private method" do
      it "raises NoMethodError" do
        expect { async.notifiable?(key) }.to raise_error(NoMethodError)
      end
    end

    context "when receiving a non-existent method" do
      it "raises NoMethodError" do
        expect { async.foo(key) }.to raise_error(NoMethodError)
      end
    end
  end

  describe "Keys" do
    describe "#new_key" do
      let(:key_options) { { user: user } }
      let(:key) { double(:personal_key, { id: 1 }.merge(key_options)) }
      subject { notification.new_key(key) }

      it { is_expected.to be_truthy }

      it "sends email to key owner" do
        expect { subject }.to have_enqueued_email(key.id, mail: "new_ssh_key_email")
      end

      describe "never emails the ghost user" do
        let(:key_options) { { user: User.ghost } }

        it "does not send email to key owner" do
          expect { subject }.to_not have_enqueued_email(key.id, mail: "new_ssh_key_email")
        end
      end
    end
  end

  describe "GpgKeys" do
    describe "#new_gpg_key" do
      let(:key) { double(:gpg_key, id: 1, user: user) }
      subject { notification.new_gpg_key(key) }

      it { is_expected.to be_truthy }

      it "sends email to key owner" do
        expect { subject }.to have_enqueued_email(key.id, mail: "new_gpg_key_email")
      end
    end
  end

  describe "AccessToken" do
    describe "#access_token_about_to_expire" do
      subject { notification.access_token_about_to_expire(user) }

      it { is_expected.to be_truthy }

      it "sends email to the token owner" do
        expect { subject }.to have_enqueued_email(user.id, mail: "access_token_about_to_expire_email")
      end
    end
  end

  describe "Notes" do
    context "issue note" do
      let(:issue) { double(:issue, id: 1) }
      let(:author) { double(:author, id: 1) }
      let(:project) { double(:project, id: 1) }
      let(:note) { double(:note, id: 1, noteable: issue, noteable_type: "Issue", noteable_ability_name: "issue", author: author, project: project) }
      subject { notification.new_note(note) }

      context "noteable_type missing" do
        before do
          allow(note).to receive(:noteable_type) { nil }
        end

        it { is_expected.to be(true) }
      end

      context "service message" do
        before do
          allow(note).to receive(:cross_reference?) { true }
          allow(note).to receive(:system?) { true }
        end

        it { is_expected.to be(true) }
      end

      context "author has opted into notifications about their activity" do
        before do
          allow(author).to receive(:notified_of_own_activity) { true }
          allow(note).to receive(:cross_reference?) { false }
          allow(note).to receive(:system?) { false }
          allow(note).to receive(:for_project_noteable?) { true }
        end

        it "emails the author" do
          expect { subject }.to have_enqueued_email(author.id, mail: "note_issue_email")
        end

        #should_email(note.author)
        #expect(find_email_for(note.author)).to have_header('X-GitLab-NotificationReason', 'own_activity')
      end
    end
  end

  def have_enqueued_email(*args, mailer: "Notify", mail: "", delivery: "deliver_now")
    have_enqueued_job(ActionMailer::DeliveryJob).with(mailer, mail, delivery, *args)
  end
end
