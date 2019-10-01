# frozen_string_literal: true

require 'spec_helper'

describe Analytics::CodeAnalyticsController do
  set(:current_user) { create(:user) }
  set(:group) { create(:group) }
  set(:project) { create(:project, :repository, group: group) }

  let(:params) do
    {
      group_id: group.full_path,
      project_id: project.full_path,
      timeframe: 'last_30_days',
    }
  end

  before do
    sign_in(current_user)
    allow_any_instance_of(Analytics::CodeAnalyticsFinder).to receive(:execute).and_return(true)
    allow_any_instance_of(Analytics::CodeAnalytics::HotspotsTree).to receive(:build).and_return(true)
    stub_licensed_features(code_analytics: true)
  end

  describe 'GET show' do
    subject { get :show, format: :html, params: {} }

    it 'authorizes visibility of code analytics feature' do
      expect(Ability).to receive(:allowed?).with(current_user, :view_code_analytics, :global).and_return(false)
      subject

      expect(response).to have_gitlab_http_status(:forbidden)
    end

    it 'returns a forbidden if user does not have premium license' do
      stub_licensed_features(code_analytics: false)
      subject

      expect(response).to have_gitlab_http_status(:forbidden)
    end
  end

  describe 'GET show.json' do
    subject { get :show, format: :json, params: params }

    context 'when signed in user has at least reporter level access' do
      before do
        group.add_reporter current_user
      end

      it 'returns an ok if user has premium license and valid params' do
        stub_licensed_features(code_analytics: true)
        expect_any_instance_of(described_class).to receive(:hotspots_tree).and_return(true)
        subject

        expect(response).to have_gitlab_http_status(:ok)
      end

      it 'returns a not_found if group is not found' do
        params['group_id'] = 'incorrect/path'
        subject

        expect(response).to have_gitlab_http_status(:not_found)
      end

      it 'returns a not_found if project is not found' do
        params['project_id'] = 'incorrect/path'
        subject

        expect(response).to have_gitlab_http_status(:not_found)
      end

      context 'with invalid timeframe' do
        it 'returns 422' do
          params['timeframe'] = 'gibberish'
          subject

          expect(response).to have_gitlab_http_status(:unprocessable_entity)
        end
      end
    end
  end
end
