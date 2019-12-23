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
        expect { subject }.to have_enqueued_job(ActionMailer::DeliveryJob).with("Notify", "new_ssh_key_email", "deliver_now", key.id)
      end

      describe "never emails the ghost user" do
        let(:key_options) { { user: User.ghost } }

        it "does not send email to key owner" do
          expect { subject }.to_not have_enqueued_job(ActionMailer::DeliveryJob).with("Notify", "new_ssh_key_email", "deliver_now", key.id)
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
        expect { subject }.to have_enqueued_job(ActionMailer::DeliveryJob).with("Notify", "new_gpg_key_email", "deliver_now", key.id)
      end
    end
  end

  describe "AccessToken" do
    describe "#access_token_about_to_expire" do
      subject { notification.access_token_about_to_expire(user) }

      it { is_expected.to be_truthy }

      it "sends email to the token owner" do
        expect { subject }.to have_enqueued_job(ActionMailer::DeliveryJob).with("Notify", "access_token_about_to_expire_email", "deliver_now", user.id)
      end
    end
  end
end
