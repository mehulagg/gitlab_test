require 'spec_helper'

describe Approvable do
  let(:merge_request) { create(:merge_request) }
  let(:project) { merge_request.project }
  let(:author) { merge_request.author }

  before do
    stub_feature_flags(approval_rules: false)
  end

  describe '#approval_feature_available?' do
    let(:project) { create(:project) }
    let(:merge_request) { create(:merge_request, source_project: project, target_project: project) }
    subject { merge_request.approval_feature_available? }

    it 'is false when feature is disabled' do
      allow(project).to receive(:feature_available?).with(:merge_request_approvers).and_return(false)

      is_expected.to be false
    end

    it 'is true when feature is enabled' do
      allow(project).to receive(:feature_available?).with(:merge_request_approvers).and_return(true)

      is_expected.to be true
    end
  end

  describe '#approvers_overwritten?' do
    subject { merge_request.approvers_overwritten? }

    it 'returns false when merge request has no approvers' do
      is_expected.to be false
    end

    it 'returns true when merge request has user approver' do
      create(:approver, target: merge_request)

      is_expected.to be true
    end

    it 'returns true when merge request has group approver' do
      group = create(:group_with_members)
      create(:approver_group, target: merge_request, group: group)

      is_expected.to be true
    end
  end

  describe '#can_approve?' do
    subject { merge_request.can_approve?(user) }

    it 'returns false if user is nil' do
      expect(merge_request.can_approve?(nil)).to be false
    end

    it 'returns true when user is included in the approvers list' do
      user = create(:approver, target: merge_request).user

      expect(merge_request.can_approve?(user)).to be true
    end

    context 'when authors can approve' do
      before do
        project.update(merge_requests_author_approval: true)
      end

      context 'when the user is the author' do
        it 'returns true when user is approver' do
          create(:approver, target: merge_request, user: author)

          expect(merge_request.can_approve?(author)).to be true
        end

        it 'returns false when user is not approver' do
          expect(merge_request.can_approve?(author)).to be false
        end
      end

      context 'when user is committer' do
        let(:user) { create(:user, email: merge_request.commits.without_merge_commits.first.committer_email) }

        before do
          project.add_developer(user)
        end

        context 'and committers can not approve' do
          before do
            project.update(merge_requests_disable_committers_approval: true)
          end

          it 'returns true when user is approver' do
            create(:approver, target: merge_request, user: user)

            expect(merge_request.can_approve?(user)).to be false
          end

          it 'returns false when user is not approver' do
            expect(merge_request.can_approve?(user)).to be false
          end
        end

        context 'and committers can approve' do
          it 'returns true when user is approver' do
            create(:approver, target: merge_request, user: user)

            expect(merge_request.can_approve?(user)).to be true
          end

          it 'returns false when user is not approver' do
            expect(merge_request.can_approve?(user)).to be false
          end
        end
      end
    end

    context 'when authors cannot approve' do
      before do
        project.update(merge_requests_author_approval: false)
      end

      it 'returns false when user is the author' do
        create(:approver, target: merge_request, user: author)

        expect(merge_request.can_approve?(author)).to be false
      end

      it 'returns true when user is a committer' do
        user = create(:user, email: merge_request.commits.without_merge_commits.first.committer_email)
        project.add_developer(user)
        create(:approver, target: merge_request, user: user)

        expect(merge_request.can_approve?(user)).to be true
      end
    end

    it 'returns false when user is unable to update the merge request' do
      user = create(:user)
      project.add_guest(user)

      expect(merge_request.can_approve?(user)).to be false
    end

    context 'when approvals are required' do
      before do
        project.update(approvals_before_merge: 1)
      end

      it 'returns true when approvals are still accepted and user still has not approved' do
        user = create(:user)
        project.add_developer(user)

        expect(merge_request.can_approve?(user)).to be true
      end

      it 'returns false when there is still one approver missing' do
        user = create(:user)
        project.add_developer(user)
        create(:approver, target: merge_request)

        expect(merge_request.can_approve?(user)).to be false
      end
    end
  end
end
