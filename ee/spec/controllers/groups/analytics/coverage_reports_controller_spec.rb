# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Groups::Analytics::CoverageReportsController do
  let(:user)  { create(:user) }
  let(:group) { create(:group) }
  let(:project) { create(:project, namespace: group) }
  let(:ref_path) { 'refs/heads/master' }

  let!(:first_coverage) { create_daily_coverage('rspec', project, 79.0, '2020-03-09') }
  let!(:last_coverage)  { create_daily_coverage('karma', project, 95.0, '2020-03-10') }

  let(:valid_request_params) do
    {
      group_id: group.name,
      start_date: '2020-03-01',
      end_date: '2020-03-31',
      ref_path: ref_path,
      format: :csv
    }
  end

  context 'without permissions' do
    before do
      sign_in(user)
    end

    describe 'GET index' do
      it 'responds 403' do
        get :index, params: valid_request_params

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
          get :index, params: valid_request_params

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
          get :index, params: valid_request_params

          expect(response).to have_gitlab_http_status(:forbidden)
        end
      end
    end

    describe 'GET index' do
      before do
        stub_licensed_features(group_coverage_reports: true)
      end

      it 'responds 200 with CSV coverage data' do
        expect(Gitlab::Tracking).to receive(:event).with(
          described_class.name,
          'download_code_coverage_csv',
          label: 'group_id',
          value: group.id
        )

        get :index, params: valid_request_params

        expect(response).to have_gitlab_http_status(:ok)
        expect(csv_response).to eq([
          %w[date group_name project_name coverage],
          [last_coverage.date.to_s, last_coverage.group_name, project.name, last_coverage.data['coverage'].to_s],
          [first_coverage.date.to_s, first_coverage.group_name, project.name, first_coverage.data['coverage'].to_s]
        ])
      end

      context 'with a project_id filter' do
        let(:params) { valid_request_params.merge(project_ids: [project.id]) }

        it 'responds 200 with CSV coverage data' do
          expect(Ci::DailyBuildGroupReportResultsByGroupFinder).to receive(:new).with({
            group: group,
            current_user: user,
            project_ids: [project.id.to_s],
            start_date: Date.parse('2020-03-01'),
            end_date: Date.parse('2020-03-31'),
            ref_path: ref_path
          }).and_call_original

          get :index, params: params
        end
      end

      context 'with an invalid format' do
        it 'responds 404' do
          get :index, params: valid_request_params.merge(format: :json)

          expect(response).to have_gitlab_http_status(:not_found)
        end
      end
    end
  end

  private

  def create_daily_coverage(group_name, project, coverage, date)
    create(
      :ci_daily_build_group_report_result,
      project: project,
      ref_path: ref_path,
      group_name: group_name,
      data: { 'coverage' => coverage },
      date: date
    )
  end
end
