# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Email::Handler do
  let(:email) { Mail.new { body 'email' } }

  describe '.for' do
    context 'key matches the reply_key of a notification' do
      it 'picks note handler' do
        expect(described_class.for(email, '1234567890abcdef1234567890abcdef')).to be_an_instance_of(Gitlab::Email::Handler::CreateNoteHandler)
      end
    end

    context 'key matches the reply_key of a notification, along with an unsubscribe suffix' do
      it 'picks unsubscribe handler' do
        expect(described_class.for(email, '1234567890abcdef1234567890abcdef-unsubscribe')).to be_an_instance_of(Gitlab::Email::Handler::UnsubscribeHandler)
      end
    end

    it 'picks issue handler if there is no merge request prefix' do
      expect(described_class.for(email, 'project+key')).to be_an_instance_of(Gitlab::Email::Handler::CreateIssueHandler)
    end

    it 'picks merge request handler if there is merge request key' do
      expect(described_class.for(email, 'project+merge-request+key')).to be_an_instance_of(Gitlab::Email::Handler::CreateMergeRequestHandler)
    end

    it 'returns nil if no handler is found' do
      expect(described_class.for(email, '')).to be_nil
    end

    it 'returns nil if provided email is nil' do
      expect(described_class.for(nil, '')).to be_nil
    end

    context 'service desk handler' do
      before do
        stub_incoming_email_setting(enabled: true, address: "incoming+%{key}@appmail.adventuretime.ooo")
        stub_config_setting(host: 'localhost')
      end

      def handler_for(fixture, mail_key)
        described_class.for(fixture_file(fixture), mail_key)
      end

      context 'a Service Desk email' do
        it 'uses the Service Desk handler when Service Desk is enabled' do
          allow(License).to receive(:feature_available?).and_call_original
          allow(License).to receive(:feature_available?).with(:service_desk).and_return(true)

          expect(handler_for('emails/service_desk.eml', 'some/project')).to be_instance_of(Gitlab::Email::Handler::ServiceDeskHandler)
        end
      end

      context 'a new issue email' do
        let!(:user) { create(:user, email: 'jake@adventuretime.ooo', incoming_email_token: 'auth_token') }

        it 'uses the create issue handler when Service Desk is enabled' do
          allow(License).to receive(:feature_available?).and_call_original
          allow(License).to receive(:feature_available?).with(:service_desk).and_return(true)

          expect(handler_for('emails/valid_new_issue.eml', 'some/project+auth_token')).to be_instance_of(Gitlab::Email::Handler::CreateIssueHandler)
        end

        # it 'uses the create issue handler when Service Desk is disabled' do
        #   allow(License).to receive(:feature_available?).and_call_original
        #   allow(License).to receive(:feature_available?).with(:service_desk).and_return(false)

        #   expect(handler_for('emails/valid_new_issue.eml', 'some/project+auth_token')).to be_instance_of(Gitlab::Email::Handler::CreateIssueHandler)
        # end
      end
    end
  end

  describe 'regexps are set properly' do
    let(:addresses) do
      %W(sent_notification_key#{Gitlab::IncomingEmail::UNSUBSCRIBE_SUFFIX} sent_notification_key path-to-project-123-user_email_token-merge-request path-to-project-123-user_email_token-issue) +
        %W(sent_notification_key#{Gitlab::IncomingEmail::UNSUBSCRIBE_SUFFIX_LEGACY} sent_notification_key path/to/project+merge-request+user_email_token path/to/project+user_email_token incoming+email-test-project_id-issue-)
    end

    it 'picks each handler at least once' do
      matched_handlers = addresses.map do |address|
        described_class.for(email, address).class
      end

      expect(matched_handlers.uniq).to match_array(Gitlab::Email::Handler.handlers)
    end

    it 'can pick exactly one handler for each address' do
      addresses.each do |address|
        matched_handlers = Gitlab::Email::Handler.handlers.select do |handler|
          handler.new(email, address).can_handle?
        end

        expect(matched_handlers.count).to eq(1), "#{address} matches #{matched_handlers.count} handlers: #{matched_handlers}"
      end
    end
  end
end
