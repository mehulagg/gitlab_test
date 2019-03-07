# frozen_string_literal: true

require 'spec_helper'

describe Vulnerabilities::FeedbackEntity do
  set(:user) { create(:user) }
  set(:project) { create(:project) }

  let(:dismiss_feedback) do
    create(:vulnerability_feedback, :sast, :dismissal,
           project: project)
  end

  let(:issue_feedback) do
    create(:vulnerability_feedback, :sast, :issue,
           issue: create(:issue, project: project),
           project: project)
  end

  let(:merge_request_feedback) do
    create(:vulnerability_feedback, :sast, :merge_request,
           issue: create(:issue, project: project),
           project: project)
  end

  let(:request) { double('request') }

  let(:entity) do
    described_class.represent(dismiss_feedback, request: request)
  end

  describe '#as_json' do
    subject { entity.as_json }

    before do
      allow(request).to receive(:current_user).and_return(user)
    end

    it { is_expected.to include(:project_id, :author, :category, :feedback_type) }

    context 'feedback type is issue' do
      let(:entity) do
        described_class.represent(issue_feedback, request: request)
      end

      context 'when allowed to destroy vulnerability feedback' do
        before do
          project.add_developer(user)
        end

        it 'does not contain destroy vulnerability feedback dismissal path' do
          expect(subject).not_to include(:destroy_vulnerability_feedback_dismissal_path)
        end
      end
    end

    context 'feedback type is merge_request' do
      let(:entity) do
        described_class.represent(merge_request_feedback, request: request)
      end

      context 'when allowed to destroy vulnerability feedback' do
        before do
          project.add_developer(user)
        end

        it 'does not contain destroy vulnerability feedback dismissal path' do
          expect(subject).not_to include(:destroy_vulnerability_feedback_dismissal_path)
        end
      end
    end

    context 'feedback type is dismissal' do
      let(:entity) do
        described_class.represent(dismiss_feedback, request: request)
      end

      context 'when not allowed to destroy vulnerability feedback' do
        before do
          project.add_guest(user)
        end

        it 'does not contain destroy vulnerability feedback dismissal path' do
          expect(subject).not_to include(:destroy_vulnerability_feedback_dismissal_path)
        end
      end

      context 'when allowed to destroy vulnerability feedback' do
        before do
          project.add_developer(user)
        end

        it 'contains destroy vulnerability feedback dismissal path' do
          expect(subject).to include(:destroy_vulnerability_feedback_dismissal_path)
        end
      end
    end
  end
end
