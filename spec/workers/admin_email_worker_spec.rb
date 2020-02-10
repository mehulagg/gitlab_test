# frozen_string_literal: true

require 'spec_helper'

describe AdminEmailWorker do
  subject(:worker) { described_class.new }

  describe '.perform' do
    context 'repository_checks disabled' do
      before do
        stub_application_setting(repository_checks_enabled: false)
      end

      context 'idempotency' do
        it_behaves_like 'can handle multiple calls without raising exceptions'
      end

      it 'does not attempt to send repository check mail when they are disabled' do
        expect(worker).not_to receive(:send_repository_check_mail)

        perform_multiple(worker: worker)
      end
    end

    context 'repository_checks enabled' do
      before do
        stub_application_setting(repository_checks_enabled: true)
      end

      context 'idempotency' do
        it_behaves_like 'can handle multiple calls without raising exceptions'
      end

      it 'checks if repository check mail should be sent' do
        expect(worker).to receive(:send_repository_check_mail).exactly(3).times

        perform_multiple(worker: worker)
      end

      it 'does not send mail when there are no failed repos' do
        expect(RepositoryCheckMailer).not_to receive(:notify)

        perform_multiple(worker: worker)
      end

      it 'send mail when there is a failed repo' do
        create(:project, last_repository_check_failed: true, last_repository_check_at: Date.yesterday)

        expect(RepositoryCheckMailer).to receive(:notify).exactly(3).and_return(spy)

        perform_multiple(worker: worker)
      end
    end
  end
end
