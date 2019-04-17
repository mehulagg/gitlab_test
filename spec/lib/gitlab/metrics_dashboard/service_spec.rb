# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::MetricsDashboard::Service, :use_clean_rails_memory_store_caching do
  let(:project) { build(:project) }
  let(:environment) { build(:environment) }

  describe 'get_dashboard' do
    it 'returns a json representation of the environment dashboard' do
      dashboard = described_class.new(project, environment).get_dashboard
      json = JSON.parse(dashboard, symbolize_names: true)

      expect(json).to include(:dashboard, :order, :panel_groups)
      expect(json[:panel_groups]).to all( include(:group, :priority, :panels) )
    end

    it 'caches the dashboard for subsequent calls' do
      expect(YAML).to receive(:load_file).once.and_call_original

      described_class.new(project, environment).get_dashboard
      described_class.new(project, environment).get_dashboard
    end
  end
end
