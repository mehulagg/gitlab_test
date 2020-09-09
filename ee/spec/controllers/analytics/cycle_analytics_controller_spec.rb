# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::CycleAnalyticsController do
  let(:user) { create(:user) }

  before do
    sign_in(user)
  end

  describe 'usage counter' do
    it 'increments usage counter' do
      expect(Gitlab::UsageDataCounters::CycleAnalyticsCounter).to receive(:count).with(:views)

      get(:show)

      expect(response).to be_successful
    end
  end

  describe 'GET show' do
    it 'renders `show` template' do
      get :show

      expect(response).to render_template :show
    end
  end
end
