# frozen_string_literal: true

require 'spec_helper'

RSpec.shared_examples 'approvals' do
  let!(:approval_rule) { create(:approval_project_rule, project: project, users: [approver, user], approvals_required: 2) }

  describe 'approve' do
    before do
      post :create,
           params: {
             namespace_id: project.namespace.to_param,
             project_id: project.to_param,
             merge_request_id: merge_request.iid
           },
           format: :json
    end

    it 'approves the merge request' do
      approvals = json_response

      expect(response).to be_successful
      expect(approvals['approvals_left']).to eq 1
      expect(approvals['approved_by'].size).to eq 1
      expect(approvals['approved_by'][0]['user']['username']).to eq user.username
      expect(approvals['user_has_approved']).to be true
      expect(approvals['user_can_approve']).to be false
      expect(approvals['suggested_approvers'].size).to eq 1
      expect(approvals['suggested_approvers'][0]['username']).to eq approver.username
    end
  end

  describe 'approvals' do
    let!(:approval) { create(:approval, merge_request: merge_request, user: approver) }

    def get_approvals
      get :show,
          params: {
            namespace_id: project.namespace.to_param,
            project_id: project.to_param,
            merge_request_id: merge_request.iid
          },
          format: :json
    end

    it 'shows approval information' do
      get_approvals

      approvals = json_response

      expect(response).to be_successful
      expect(approvals['approvals_left']).to eq 1
      expect(approvals['approved_by'].size).to eq 1
      expect(approvals['approved_by'][0]['user']['username']).to eq approver.username
      expect(approvals['user_has_approved']).to be false
      expect(approvals['user_can_approve']).to be true
      expect(approvals['suggested_approvers'].size).to eq 1
      expect(approvals['suggested_approvers'][0]['username']).to eq user.username
    end
  end

  describe 'unapprove' do
    let!(:approval) { create(:approval, merge_request: merge_request, user: user) }

    before do
      delete :destroy,
             params: {
               namespace_id: project.namespace.to_param,
               project_id: project.to_param,
               merge_request_id: merge_request.iid
             },
             format: :json
    end

    it 'unapproves the merge request' do
      approvals = json_response

      expect(response).to be_successful
      expect(approvals['approvals_left']).to eq 2
      expect(approvals['approved_by']).to be_empty
      expect(approvals['user_has_approved']).to be false
      expect(approvals['user_can_approve']).to be true
      expect(approvals['suggested_approvers'].size).to eq 2
    end
  end
end

RSpec.describe Projects::MergeRequests::ApprovalsController do
  include ProjectForksHelper

  let(:project) { create(:project, :repository) }
  let(:merge_request) { create(:merge_request_with_diffs, source_project: project, author: create(:user)) }
  let(:user) { project.creator }
  let(:approver) { create(:user) }

  before do
    project.add_developer(approver)

    sign_in(approver)
  end

  context 'project' do
    it_behaves_like 'approvals'
  end

  context 'with a forked project' do
    let(:forked_project) { fork_project(project, fork_owner, repository: true) }
    let(:fork_owner) { create(:user) }

    before do
      project.add_developer(fork_owner)
      merge_request.update!(source_project: forked_project)
      forked_project.add_reporter(user)
    end

    it_behaves_like 'approvals'
  end
end
