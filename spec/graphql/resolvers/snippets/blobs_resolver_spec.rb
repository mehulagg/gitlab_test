# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::Snippets::BlobsResolver do
  include GraphqlHelpers

  describe '#resolve' do
    let_it_be(:current_user) { create(:user) }
    let_it_be(:snippet) { create(:personal_snippet, :private, :repository, author: current_user) }
    let_it_be(:blobs) { snippet.blobs }

    context 'when user is not authorized' do
      let(:other_user) { create(:user) }

      it 'raises an error' do
        expect do
          resolve_blobs(snippet, user: other_user)
        end.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
      end
    end

    context 'when using no filter' do
      it 'returns all snippet blobs' do
        expect(resolve_blobs(snippet)).to contain_exactly(*blobs)
      end
    end

    context 'when using filters' do
      context 'when setting path as a single string' do
        it 'returns an array of files' do
          expect(resolve_blobs(snippet, args: { paths: 'CHANGELOG' })).to contain_exactly(snippet.repository.blob_at(nil, 'CHANGELOG'))
        end
      end

    #   it 'returns the snippets by visibility' do
    #     aggregate_failures do
    #       expect(resolve_blobs(args: { visibility: 'are_private' })).to contain_exactly(private_personal_snippet)
    #       expect(resolve_blobs(args: { visibility: 'are_internal' })).to contain_exactly(internal_project_snippet)
    #       expect(resolve_blobs(args: { visibility: 'are_public' })).to contain_exactly(public_personal_snippet)
    #     end
    #   end

    #   it 'returns the snippets by single gid' do
    #     snippets = resolve_blobs(args: { ids: private_personal_snippet.to_global_id })

    #     expect(snippets).to contain_exactly(private_personal_snippet)
    #   end

    #   it 'returns the snippets by array of gid' do
    #     args = {
    #       ids: [private_personal_snippet.to_global_id, public_personal_snippet.to_global_id]
    #     }

    #     snippets = resolve_blobs(args: args)

    #     expect(snippets).to contain_exactly(private_personal_snippet, public_personal_snippet)
    #   end

    #   it 'returns an error if the gid is invalid' do
    #     args = {
    #       ids: [private_personal_snippet.to_global_id, 'foo']
    #     }

    #     expect do
    #       resolve_blobs(args: args)
    #     end.to raise_error(Gitlab::Graphql::Errors::ArgumentError)
    #   end
    end
  end

  def resolve_blobs(snippet, user: current_user, args: {})
    resolve(described_class, args: args, ctx: { current_user: user }, obj: snippet)
  end
end
