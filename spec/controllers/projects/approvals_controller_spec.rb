# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::MergeRequests::ApprovalsController do
  let(:project) { create(:project, :repository) }
  let(:merge_request) { create(:merge_request_with_diffs, source_project: project, author: create(:user)) }
  let(:user) { project.creator }
  let(:viewer) { user }
  let!(:approver) { create(:user) }

  before do
    sign_in(viewer)

    project.add_developer(approver)
  end

  describe 'approve' do
    def approve
      post :create,
           params: {
             namespace_id: project.namespace.to_param,
             project_id: project.to_param,
             merge_request_id: merge_request.iid
           },
           format: :json
    end

    it 'approves the merge request' do
      expect { approve }.to change { merge_request.approvals.count }.from(0).to(1)

      expect(response).to be_successful
    end
  end

  describe 'approvals' do
    let!(:approval) { create(:approval, merge_request: merge_request, user: approver) }

    before do
      get :show,
          params: {
            namespace_id: project.namespace.to_param,
            project_id: project.to_param,
            merge_request_id: merge_request.iid
          },
          format: :json
    end

    it 'shows approval information' do
      expect(response).to be_successful
    end
  end

  describe 'unapprove' do
    let!(:approval) { create(:approval, merge_request: merge_request, user: user) }

    def unapprove
      delete :destroy,
             params: {
               namespace_id: project.namespace.to_param,
               project_id: project.to_param,
               merge_request_id: merge_request.iid
             },
             format: :json
    end

    it 'unapproves the merge request' do
      expect { unapprove }.to change { merge_request.approvals.count }.from(1).to(0)

      expect(response).to be_successful
    end
  end
end
