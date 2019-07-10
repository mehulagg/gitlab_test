# frozen_string_literal: true

require 'spec_helper'

describe UserSerializer do
  let(:user1) { create(:user) }
  let(:user2) { create(:user) }

  context 'serializer with merge request context' do
    let(:project) { create(:project) }
    let(:merge_request) { create(:merge_request) }
    let(:serializer) { UserSerializer.new(merge_request_iid: merge_request.iid) }

    before do
      allow(project).to(
        receive_message_chain(:merge_requests, :find_by_iid)
          .with(merge_request.iid).and_return(merge_request)
      )

      allow(merge_request).to receive(:can_be_merged_by?).with(user1).and_return(true)
      allow(merge_request).to receive(:can_be_merged_by?).with(user2).and_return(false)
    end

    it 'returns a user with can_merge option' do
      serialized_user1, serialized_user2 = serializer.represent([user1, user2], project: project).as_json

      expect(serialized_user1).to include("id" => user1.id, "can_merge" => true)
      expect(serialized_user2).to include("id" => user2.id, "can_merge" => false)
    end
  end
end
