# frozen_string_literal: true

require 'spec_helper'

describe API::Analytics::GroupActivityAnalytics do
  let_it_be(:group) { create(:group) }
  let(:current_user) { reporter }

  let_it_be(:reporter) do
    create(:user).tap { |u| group.add_reporter(u) }
  end
  let_it_be(:anonymous_user) { create(:user) }

  before do
    stub_licensed_features(group_activity_analytics: true)
  end

  describe 'GET group_activity' do
    let(:params) { { group_path: group.full_path } }

    subject(:api_call) do
      get api('/analytics/group_activity?', current_user), params: params
    end

    it 'is successful' do
      api_call

      expect(response).to have_gitlab_http_status(:ok)
    end

    context 'when user has no authorization to view a private group' do
      let(:current_user) { anonymous_user }

      before do
        group.update!(visibility_level: Gitlab::VisibilityLevel::PRIVATE)
      end

      it 'is returns `not_found`' do
        api_call

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end

    context 'when feature is not available in plan' do
      before do
        stub_licensed_features(group_activity_analytics: false)
      end

      it 'is returns `forbidden`' do
        api_call

        expect(response).to have_gitlab_http_status(:forbidden)
      end
    end

    context 'when group_path is not specified' do
      subject(:api_call) { get api('/analytics/group_activity', current_user) }

      it 'is returns `bad_request`' do
        api_call

        expect(response).to have_gitlab_http_status(:bad_request)
      end
    end
  end
end
