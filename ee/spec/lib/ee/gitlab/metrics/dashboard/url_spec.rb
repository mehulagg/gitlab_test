# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Metrics::Dashboard::Url do
  describe '#clusters_regex' do
    let(:url) do
      Gitlab::Routing.url_helpers.namespace_project_cluster_url(
        'foo',
        'bar',
        '1',
        group: 'Cluster Health',
        title: 'Memory Usage',
        y_label: 'Memory 20(GiB)',
        anchor: 'title'
      )
    end

    let(:expected_params) do
      {
        'url' => url,
        'namespace' => 'foo',
        'project' => 'bar',
        'cluster_id' => '1',
        'query' => '?group=Cluster+Health&title=Memory+Usage&y_label=Memory+20%28GiB%29',
        'anchor' => '#title'
      }
    end

    subject { described_class.clusters_regex }

    it_behaves_like 'a regex which matches the expected url'
    it_behaves_like 'does not match non-matching urls'
  end
end
