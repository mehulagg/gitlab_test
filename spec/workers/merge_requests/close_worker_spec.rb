# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MergeRequests::CloseWorker do
  let!(:merge_request) { create(:merge_request, source_branch: "markdown") }
  let!(:project) { merge_request.target_project }
  let!(:user) { merge_request.author }
  let(:service) { double("CloseService") }

  it "calls MergeRequest::CloseService" do
    expect(MergeRequests::CloseService).to receive(:new).with(project, user).and_return(service)
    expect(service).to receive(:execute).with(merge_request)

    described_class.new.perform(project.id, user.id, merge_request.id)
  end

  it_behaves_like "an idempotent worker" do
    let(:job_args) { [project.id, user.id, merge_request.id] }
  end
end
