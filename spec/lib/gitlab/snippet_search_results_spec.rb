# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::SnippetSearchResults do
  include SearchHelpers

  let!(:snippet) { create(:snippet, content: 'foo', file_name: 'foo') }
  let(:results) { described_class.new(snippet.author, 'foo') }

  describe '#limited_snippet_titles_count' do
    it 'returns the amount of matched snippet titles' do
      expect(results.limited_snippet_titles_count).to eq(1)
    end
  end

  describe '#limited_snippet_blobs_count' do
    it 'returns the amount of matched snippet blobs' do
      expect(results.limited_snippet_blobs_count).to eq(1)
    end
  end

  describe '#formatted_count' do
    using RSpec::Parameterized::TableSyntax

    where(:scope, :count_method, :expected) do
      'snippet_titles' | :limited_snippet_titles_count   | max_limited_count
      'snippet_blobs'  | :limited_snippet_blobs_count    | max_limited_count
      'projects'       | :limited_projects_count         | max_limited_count
      'unknown'        | nil                             | nil
    end

    with_them do
      it 'returns the expected formatted count' do
        expect(results).to receive(count_method).and_return(1234) if count_method
        expect(results.formatted_count(scope)).to eq(expected)
      end
    end
  end

  context "when count_limit is lower than total amount" do
    before do
      allow(results).to receive(:count_limit).and_return(1)

      create(:snippet, content: 'foo', file_name: 'foo')
      create(:project_snippet, content: 'foo', file_name: 'foo')
    end

    describe '#limited_snippet_titles_count' do
      it 'runs single SQL query to get the limited amount of snippets' do
        expect(results).to receive(:snippet_titles).with(personal_only: true).and_call_original
        expect(results).not_to receive(:snippet_titles).with(no_args)

        expect(results.limited_snippet_titles_count).to eq(1)
      end
    end

    describe '#limited_snippet_blobs_count' do
      it 'runs single SQL query to get the limited amount of snippets' do
        expect(results).to receive(:snippet_blobs).with(personal_only: true).and_call_original
        expect(results).not_to receive(:snippet_blobs).with(no_args)

        expect(results.limited_snippet_blobs_count).to eq(1)
      end
    end
  end

  context "when count_limit is higher than total amount" do
    let!(:project) { create(:project, :public) }

    before do
      create(:snippet, :public, content: 'foo', file_name: 'foo')
      create(:project_snippet, :public, project: project, content: 'foo', file_name: 'foo')
    end

    describe '#limited_snippet_titles_count' do
      it 'runs multiple queries to get the limited amount of snippets' do
        expect(results).to receive(:snippet_titles).with(personal_only: true).and_call_original
        expect(results).to receive(:snippet_titles).with(no_args).and_call_original

        expect(results.limited_snippet_titles_count).to eq(3)
      end
    end

    describe '#limited_snippet_blobs_count' do
      it 'runs multiple queries to get the limited amount of snippets' do
        expect(results).to receive(:snippet_blobs).with(personal_only: true).and_call_original
        expect(results).to receive(:snippet_blobs).with(no_args).and_call_original

        expect(results.limited_snippet_blobs_count).to eq(3)
      end
    end
  end
end
