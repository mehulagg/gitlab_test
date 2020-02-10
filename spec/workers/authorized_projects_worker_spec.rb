# frozen_string_literal: true

require 'spec_helper'

describe AuthorizedProjectsWorker do
  describe '#perform' do
    let(:user) { create(:user) }

    it "refreshes user's authorized projects" do
      expect_any_instance_of(User).to receive(:refresh_authorized_projects).at_least(1)

      perform_multiple(user.id, exec_times: 1)
    end

    context 'idempotency' do
      it_behaves_like 'can handle multiple calls without raising exceptions' do
        let(:job_args) { user.id }
      end
    end

    context "when the user is not found" do
      it "does nothing" do
        expect_any_instance_of(User).not_to receive(:refresh_authorized_projects)

        perform_multiple(-1)
      end

      context 'idempotency' do
        it_behaves_like 'can handle multiple calls without raising exceptions' do
          let(:job_args) { -1 }
        end
      end
    end
  end
end
