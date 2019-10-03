# frozen_string_literal: true

require 'spec_helper'

describe Elastic::Latest::ApplicationClassProxy, :elastic_stub do
  subject { described_class.new(Snippet, current_es_index) }

  describe '#delete_document' do
    it 'calls delete on the client' do
      expect(subject.client).to receive(:delete).with(
        index: subject.index_name,
        type: subject.document_type,
        id: 'es_id',
        routing: 'es_parent'
      )

      subject.delete_document('es_id', 'es_parent')
    end
  end

  describe '#delete_child_documents' do
    it 'calls delete_by_query on the client' do
      expect(subject.client).to receive(:delete_by_query).with(
        index: subject.index_name,
        routing: 'es_id',
        body: {
          query: {
            has_parent: {
              parent_type: subject.es_type,
              query: {
                term: { id: 'record_id' }
              }
            }
          }
        }
      )

      subject.delete_child_documents('es_id', 'record_id')
    end
  end
end
