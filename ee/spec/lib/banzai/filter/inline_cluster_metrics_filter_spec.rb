# frozen_string_literal: true

require 'spec_helper'

describe Banzai::Filter::InlineClusterMetricsFilter do
  include FilterSpecHelper

  let!(:cluster) { create(:cluster) }
  let!(:project) { create(:project) }
  let(:params) { ['foo', 'bar', cluster.id] }
  let(:query_params) { { group: 'Pizza metrics', title: 'Pizza Consumption', y_label: 'Slice Count', cluster_id: cluster.id, project: project.id, namespace: project.namespace.id } }

  # cluster_id: cluster.id, project: project.id, namespace: project.namespace.id

  let(:trigger_url) { urls.metrics_namespace_project_cluster_url(*params, query_params) }
  let(:dashboard_url) { urls.metrics_dashboard_namespace_project_cluster_url(*params, **query_params, embedded: true) }

  it_behaves_like 'a metrics embed filter'

  context 'without query params specified' do
    let(:query_params) { {} }

    it 'does not add metric div' do
      expect(doc.to_s).to eq(input)
    end
  end
end
