# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Groups::Analytics::CoverageReportsController do
  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, namespace: group) }

  let_it_be(:daily_coverage_data) do
    create(:ci_daily_build_group_report_result,
      project: project,
      ref_path: 'refs/heads/master',
      group_name: 'rspec',
      data: { 'coverage' => 80.0 },
      date: '2020-07-09'
    )
  end

  context 'without permissions' do
    before do
      sign_in(user)
    end

    describe 'GET index' do
      it 'responds 403' do
        get :index, params: { group_id: group.name, format: :csv }

        expect(response).to have_gitlab_http_status(:forbidden)
      end
    end
  end

  context 'with permissions' do
    before do
      group.add_owner(user)
      sign_in(user)
    end

    context 'without a license' do
      before do
        stub_licensed_features(group_coverage_reports: false)
      end

      describe 'GET index' do
        it 'responds 403 because the feature is not licensed' do
          get :index, params: { group_id: group.name, format: :csv }

          expect(response).to have_gitlab_http_status(:forbidden)
        end
      end
    end

    context 'with the feature flag shut off' do
      before do
        stub_licensed_features(group_coverage_reports: true)
        stub_feature_flags(group_coverage_reports: false)
      end

      describe 'GET index' do
        it 'responds 403 because the feature is not licensed' do
          get :index, params: { group_id: group.name, format: :csv }

          expect(response).to have_gitlab_http_status(:forbidden)
        end
      end
    end

    describe 'GET index' do
      before do
        stub_licensed_features(group_coverage_reports: true)
      end

      it 'responds 200 OK' do
        get :index, params: { group_id: group.name, format: :json }

        expect(response).to have_gitlab_http_status(:ok)
        expect(Gitlab::Json.parse(response.body)).to eq(Analytics::GroupCoverageReport.new(group: group, user: user).daily_summary.as_json)
      end
    end
  end
end
