# frozen_string_literal: true

require 'spec_helper'

describe Elastic::MultiVersionClassProxy, :elastic_stub do
  subject { described_class.new(ProjectSnippet) }

  describe '#version' do
    it 'returns class proxy in specified version' do
      result = subject.version(current_es_index)

      expect(result).to be_a(Elastic::V12p1::SnippetClassProxy)
      expect(result.target).to eq(ProjectSnippet)
    end

    context 'repository' do
      it 'returns class proxy in specified version' do
        repository_proxy = described_class.new(Repository)
        repository_result = repository_proxy.version(current_es_index)
        wiki_proxy = described_class.new(ProjectWiki)
        wiki_result = wiki_proxy.version(current_es_index)

        expect(repository_result).to be_a(Elastic::V12p1::RepositoryClassProxy)
        expect(repository_result.target).to eq(Repository)
        expect(repository_result.es_index).to eq(current_es_index)

        expect(wiki_result).to be_a(Elastic::V12p1::ProjectWikiClassProxy)
        expect(wiki_result.target).to eq(ProjectWiki)
        expect(wiki_result.es_index).to eq(current_es_index)
      end
    end
  end

  describe '#index_name' do
    it 'returns the configured ES index name' do
      expect(subject.index_name).to eq(current_es_index.name)
    end
  end

  describe 'method forwarding' do
    let(:old_target) { subject.version(current_es_index) }
    let(:new_target) { subject.version(current_es_index) }
    let(:response) do
      { "_index" => "gitlab-test", "_type" => "doc", "_id" => "snippet_1", "_version" => 3, "result" => "updated", "_shards" => { "total" => 2, "successful" => 1, "failed" => 0 }, "created" => false }
    end

    before do
      allow(subject).to receive(:elastic_reading_target).and_return(old_target)
      allow(subject).to receive(:elastic_writing_targets).and_return([old_target, new_target])
    end

    it 'forwards methods which should touch all write targets' do
      Elastic::V12p1::SnippetClassProxy.methods_for_all_write_targets.each do |method|
        expect(new_target).to respond_to(method)
        expect(old_target).to respond_to(method)

        expect(new_target).to receive(method).and_return(response)
        expect(old_target).to receive(method).and_return(response)

        subject.public_send(method)
      end
    end

    it 'forwards read methods to only reading target' do
      expect(old_target).to receive(:search)
      expect(new_target).not_to receive(:search)

      subject.search

      expect(subject).not_to respond_to(:method_missing)
    end

    it 'does not forward write methods which should touch specific version' do
      Elastic::V12p1::SnippetClassProxy.methods_for_one_write_target.each do |method|
        expect(subject).not_to respond_to(method)
      end
    end
  end
end
