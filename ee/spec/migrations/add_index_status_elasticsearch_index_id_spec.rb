# frozen_string_literal: true

require 'spec_helper'
require Rails.root.join('db', 'migrate', '20191120155750_add_index_status_elasticsearch_index_id')

describe AddIndexStatusElasticsearchIndexId, :migration do
  context 'with existing index statuses' do
    let(:users) { table(:users) }
    let(:namespaces) { table(:namespaces) }
    let(:projects) { table(:projects) }
    let(:index_statuses) { table(:index_statuses) }
    let(:elasticsearch_indices) { table(:elasticsearch_indices) }

    before do
      author = users.create!(id: 1, projects_limit: 10)

      namespace = namespaces.create!(id: 1, name: 'namespace_1', path: 'namespace_1', owner_id: author.id)

      project1 = projects.create!(id: 1, creator_id: author.id, namespace_id: namespace.id)
      project2 = projects.create!(id: 2, creator_id: author.id, namespace_id: namespace.id)

      index_statuses.create!(id: 1, project_id: project1.id)
      index_statuses.create!(id: 2, project_id: project2.id)
    end

    context 'with an existing Elasticsearch index' do
      before do
        elasticsearch_indices.create!(id: 1, name: 'one', friendly_name: 'one', version: 'V12p1', urls: ['http://localhost:9200'])
        elasticsearch_indices.create!(id: 2, name: 'two', friendly_name: 'two', version: 'V12p1', urls: ['http://localhost:9200'])
      end

      it 'initializes the elasticsearch_index_id to the first index' do
        reversible_migration do |migration|
          migration.before -> do
            expect(index_statuses.count).to be(2)
          end

          migration.after -> do
            index_statuses.reset_column_information

            expect(index_statuses.pluck(:elasticsearch_index_id)).to eq([1, 1])
            expect(index_statuses.column_defaults.fetch('elasticsearch_index_id')).to be_nil
          end
        end
      end
    end

    context 'without an existing Elasticsearch index' do
      it 'deletes existing index statuses' do
        reversible_migration do |migration|
          migration.after -> do
            index_statuses.reset_column_information

            expect(index_statuses.count).to be(0)
            expect(index_statuses.column_defaults.fetch('elasticsearch_index_id')).to be_nil
          end
        end
      end
    end
  end
end
