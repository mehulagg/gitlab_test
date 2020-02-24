# frozen_string_literal: true

require 'spec_helper'

describe PaginatedDiffEntity do
  let(:user) { create(:user) }
  let(:request) { double('request', current_user: user) }
  let(:merge_request) { create(:merge_request, :with_diffs) }
  let(:diff_batch) { merge_request.merge_request_diff.diffs_in_batch(2, 3, diff_options: nil) }
  let(:options) do
    {
      request: request,
      merge_request: merge_request,
      pagination_data: diff_batch.pagination_data
    }
  end
  let(:entity) { described_class.new(diff_batch, options) }

  subject { entity.as_json }

  it 'exposes diff_files' do
    expect(subject[:diff_files]).to be_present
  end

  it 'exposes pagination data' do
    expect(subject[:pagination]).to eq(
      current_page: 2,
      next_page: 3,
      next_page_href: "/#{merge_request.project.full_path}/-/merge_requests/#{merge_request.iid}/diffs_batch.json?page=3",
      total_pages: 7
    )
  end

  describe 'exposes head_version_path' do
    before do
      allow(merge_request).to receive(:diffable_merge_ref?)
        .and_return(diffable_merge_ref)
    end

    context 'merge request can be merged' do
      let(:diffable_merge_ref) { true }

      it 'returns diff path with diff_head param set' do
        expect(subject[:head_version_path]).to eq(
          "/#{merge_request.project.full_path}/-/merge_requests/#{merge_request.iid}/diffs?diff_head=true"
        )
      end
    end

    context 'merge request cannot be merged' do
      let(:diffable_merge_ref) { false }

      it 'returns diff path with diff_head param set' do
        expect(subject[:head_version_path]).to be_nil
      end
    end
  end
end
