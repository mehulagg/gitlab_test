require 'spec_helper'

describe Gitlab::Graphql::Loaders::NamespaceStatisticsLoader do
  describe '#find' do
    it 'only queries once for statistics' do
      stats = create_list(:project_statistics, 2)
      namespace1 = stats.first.project.namespace
      namespace2 = stats.last.project.namespace

      expect do
        described_class.new(namespace1.id).find
        described_class.new(namespace2.id).find
      end.not_to exceed_query_limit(1)
    end
  end
end
