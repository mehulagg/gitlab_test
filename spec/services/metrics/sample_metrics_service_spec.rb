# frozen_string_literal: true

require 'spec_helper'

describe Metrics::SampleMetricsService do
  describe 'query' do
    context 'when the file is not found' do
      subject { -> { described_class.new(nil).query } }

      it { is_expected.to raise_error(Metrics::SampleMetricsService::MissingSampleMetricsFile) }
    end

    context 'when the file is found' do
      let(:identifier) { 'sample_metric_query_result' }
      let(:source) { File.join(Rails.root, 'spec/fixtures/gitlab/sample_metrics', "#{identifier}.yml") }
      let(:destination) { File.join(Rails.root, Metrics::SampleMetricsService::DIRECTORY, "#{identifier}.yml") }

      before do
        directory_name = Metrics::SampleMetricsService::DIRECTORY
        Dir.mkdir(directory_name) unless File.exist?(directory_name)
        FileUtils.cp(source, destination)
      end

      subject { described_class.new(identifier).query }

      it { expect(subject[0]['values']).not_to be_empty }

      after do
        FileUtils.rm(destination)
      end
    end
  end
end
