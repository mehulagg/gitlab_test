# frozen_string_literal: true

require 'rake_helper'

describe 'gitlab:generate_sample_prometheus_data rake task' do
  let(:cluster) { create(:cluster, :provided_by_user, :project) }
  let(:environment) { create(:environment, project: cluster.project) }
  let(:sample_query_file) { File.join(Rails.root, Metrics::SampleMetricsService::DIRECTORY, 'test_query_result.yml') }
  let!(:metric) { create(:prometheus_metric, project: cluster.project, identifier: 'test_query_result') }

  before do
    Rake.application.rake_require 'tasks/gitlab/generate_sample_prometheus_data'
    allow_any_instance_of(Environment).to receive_message_chain(:prometheus_adapter, :prometheus_client, :query_range) { sample_query_result }
    run_rake_task('gitlab:generate_sample_prometheus_data', [environment.id])
  end

  it 'creates the file correctly' do
    expect(File.exist?(sample_query_file)).to be true
  end

  it 'returns the correct results' do
    expect(sample_query_result[0]['values']).not_to be_empty
  end

  after do
    FileUtils.rm(sample_query_file)
  end
end

def sample_query_result
  file = File.join(Rails.root, 'spec/fixtures/gitlab/sample_metrics', 'sample_metric_query_result.yml')
  YAML.load_file(File.expand_path(file, __dir__))
end
