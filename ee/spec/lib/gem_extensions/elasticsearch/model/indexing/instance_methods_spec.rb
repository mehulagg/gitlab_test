# frozen_string_literal: true

require 'spec_helper'

describe GemExtensions::Elasticsearch::Model::Indexing::InstanceMethods, :elastic_stub do
  subject { Elastic::Latest::ProjectInstanceProxy.new(project, current_es_index) }

  let(:project) { Project.new(id: 1) }

  describe '#index_document' do
    it 'overrides _id with type being prepended' do
      expect(subject.client).to receive(:index).with(
        index: current_es_index.name,
        type: 'doc',
        id: 'project_1',
        body: subject.as_indexed_json
      )

      subject.index_document
    end
  end

  describe '#delete_document' do
    it 'raises an exception' do
      expect do
        subject.delete_document
      end.to raise_error(NotImplementedError)
    end
  end
end
