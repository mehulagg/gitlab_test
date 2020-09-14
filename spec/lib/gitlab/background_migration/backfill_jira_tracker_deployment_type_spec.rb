# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::BackgroundMigration::BackfillJiraTrackerDeploymentType, :migration, schema: 20200910155617 do
  let_it_be(:jira_service_temp) { described_class::JiraServiceTemp }
  let_it_be(:jira_tracker_data_temp) { described_class::JiraTrackerDataTemp }
  let_it_be(:api_host) { 'https://api.jira.com' }
  let_it_be(:rest_url) { "#{api_host}/rest/api/2/serverInfo" }
  let_it_be(:server_info_results) { { 'deploymentType' => 'Cloud' } }

  subject { described_class.new }

  describe '#perform' do
    before do
      WebMock.stub_request(:get, /serverInfo/).to_return(body: server_info_results.to_json )
    end

    context 'when using an invalid jira service' do
      it 'does not query server without an existing service' do
        subject.perform(non_existing_record_id)

        expect(WebMock).not_to have_requested(:get, /serverInfo/)
      end

      it 'does not query server with an inactive service' do
        jira_service = jira_service_temp.create!(type: 'JiraService', active: false, category: 'issue_tracker')
        jira_tracker_data = jira_tracker_data_temp.create!(service_id: jira_service.id, url: api_host, deployment_type: 1)

        subject.perform(jira_tracker_data.id)

        expect(WebMock).not_to have_requested(:get, /serverInfo/)
      end

      it 'does not query server if deployment already set' do
        jira_service = jira_service_temp.create!(type: 'JiraService', active: true, category: 'issue_tracker')
        jira_tracker_data = jira_tracker_data_temp.create!(service_id: jira_service.id, url: api_host, deployment_type: 1)

        subject.perform(jira_tracker_data.id)

        expect(WebMock).not_to have_requested(:get, /serverInfo/)
      end

      it 'does not query server if no url is set' do
        jira_service = jira_service_temp.create!(type: 'JiraService', active: true, category: 'issue_tracker')
        jira_tracker_data = jira_tracker_data_temp.create!(service_id: jira_service.id, deployment_type: 0)

        subject.perform(jira_tracker_data.id)

        expect(WebMock).not_to have_requested(:get, /serverInfo/)
      end
    end

    context 'when using a valid service' do
      let!(:jira_service) { jira_service_temp.create!(type: 'JiraService', active: true, category: 'issue_tracker') }
      let!(:jira_tracker_data) do
        jira_tracker_data_temp.create!(service_id: jira_service.id,
                                       url: api_host, deployment_type: 0)
      end

      it 'sets the deployment_type to cloud' do
        subject.perform(jira_tracker_data.id)

        expect(jira_tracker_data.reload.deployment_cloud?).to be_truthy
        expect(WebMock).to have_requested(:get, rest_url)
      end

      describe 'with a Jira Server' do
        let_it_be(:server_info_results) { { 'deploymentType' => 'Server' } }

        it 'sets the deployment_type to server' do
          subject.perform(jira_tracker_data.id)

          expect(jira_tracker_data.reload.deployment_server?).to be_truthy
          expect(WebMock).to have_requested(:get, rest_url)
        end
      end

      describe 'with api_url specified' do
        let!(:jira_tracker_data) do
          jira_tracker_data_temp.create!(service_id: jira_service.id,
                                         api_url: api_host, deployment_type: 0)
        end

        it 'sets the deployment_type to cloud' do
          subject.perform(jira_tracker_data.id)

          expect(jira_tracker_data.reload.deployment_cloud?).to be_truthy
          expect(WebMock).to have_requested(:get, rest_url)
        end
      end
    end

    context 'when Jira api raises an error' do
      let!(:jira_service) { jira_service_temp.create!(type: 'JiraService', active: true, category: 'issue_tracker') }
      let!(:jira_tracker_data) do
        jira_tracker_data_temp.create!(service_id: jira_service.id,
                                       url: api_host, deployment_type: 0)
      end

      it 'catches and logs the error' do
        error_message = 'Some specific failure.'

        WebMock.stub_request(:get, rest_url)
          .to_raise(JIRA::HTTPError.new(double(message: error_message)))

        expect(::Gitlab::BackgroundMigration::Logger).to receive(:error).with(
          jira_service_id: jira_service.id,
          message: 'Error querying Jira',
          migrator: 'BackfillJiraTrackerDeploymentType',
          project_id: nil,
          client_url: api_host,
          error: error_message
        )

        subject.perform(jira_tracker_data.id)
      end
    end
  end
end
