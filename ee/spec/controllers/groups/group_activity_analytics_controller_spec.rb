# frozen_string_literal: true

require 'spec_helper'

describe Groups::GroupActivityAnalyticsController do
  before do
    sign_in(user)
  end

  it 'returns 404 when feature is not enabled' do
    get :show, params: { group_id: group.path }

    expect(response).to have_gitlab_http_status(:not_found)
  end
end
