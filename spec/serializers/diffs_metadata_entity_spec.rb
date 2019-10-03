# frozen_string_literal: true

require 'spec_helper'

describe DiffsMetadataEntity do
  let(:user) { create(:user) }
  let(:project) { create(:project, :repository) }
  let(:request) { EntityRequest.new(project: project, current_user: user) }
  let(:merge_request) { create(:merge_request_with_diffs, target_project: project, source_project: project) }
  let(:merge_request_diffs) { merge_request.merge_request_diffs }

  let(:entity) do
    described_class.new(merge_request_diffs.first.diffs,
                        request: request,
                        merge_request: merge_request,
                        merge_request_diffs: merge_request_diffs)
  end

  context 'as json' do
    subject { entity.as_json }

    it 'contain only required attributes' do
      expect(subject.keys).to contain_exactly(
        # Inherited attributes
        :real_size, :size, :branch_name,
        :target_branch_name, :commit, :merge_request_diff,
        :start_version, :latest_diff, :latest_version_path,
        :added_lines, :removed_lines, :render_overflow_warning,
        :email_patch_path, :plain_diff_path,
        :merge_request_diffs,
        # Attributes
        :diff_stats
      )
    end
  end
end
