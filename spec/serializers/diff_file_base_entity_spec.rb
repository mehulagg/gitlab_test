# frozen_string_literal: true

require 'spec_helper'

describe DiffFileBaseEntity do
  let(:project) { create(:project, :repository) }
  let(:repository) { project.repository }
  let(:entity) { described_class.new(diff_file, options).as_json }

  context 'diff for a changed submodule' do
    let(:commit_sha_with_changed_submodule) do
      "cfe32cf61b73a0d5e9f13e774abde7ff789b1660"
    end
    let(:commit) { project.commit(commit_sha_with_changed_submodule) }
    let(:options) { { request: {}, submodule_links: Gitlab::SubmoduleLinks.new(repository) } }
    let(:diff_file) { commit.diffs.diff_files.to_a.last }

    it do
      expect(entity[:blob_id]).to eq('409f37c4f05865e4fb208c771485f211a22c4c2d')
      expect(entity[:submodule]).to eq(true)
      expect(entity[:submodule_link]).to eq("https://github.com/randx/six")
      expect(entity[:submodule_tree_url]).to eq(
        "https://github.com/randx/six/tree/409f37c4f05865e4fb208c771485f211a22c4c2d"
      )
    end
  end

  context 'contains raw sizes for the blob' do
    let(:commit) { project.commit('png-lfs') }
    let(:options) { { request: {} } }
    let(:diff_file) { commit.diffs.diff_files.to_a.second }

    it do
      expect(entity[:old_size]).to eq(1219696)
      expect(entity[:new_size]).to eq(132)
    end
  end

  context 'contains basic attributes' do
    let(:commit) { project.commit }
    let(:options) { { request: {} } }
    let(:diff_file) { commit.diffs.diff_files.to_a.first }

    it do
      expect(entity[:content_sha]).to eq('b83d6e391c22777fca1ed3012fce84f633d7fed0')
      expect(entity[:old_path_html]).to eq("bar/branch-test.txt")
      expect(entity[:new_path_html]).to eq("bar/branch-test.txt")
      expect(entity[:formatted_external_url]).to eq(nil)
      expect(entity[:external_url]).to eq(nil)
      expect(entity[:readable_text]).to eq(true)
      expect(entity[:can_modify_blob]).to eq(false)
      expect(entity[:file_path]).to eq("bar/branch-test.txt")
      expect(entity[:old_path]).to eq("bar/branch-test.txt")
      expect(entity[:new_path]).to eq("bar/branch-test.txt")
      expect(entity[:new_file]).to eq(true)
      expect(entity[:renamed_file]).to eq(false)
      expect(entity[:deleted_file]).to eq(false)
      expect(entity[:mode_changed]).to eq(true)
      expect(entity[:a_mode]).to eq("0")
      expect(entity[:b_mode]).to eq("100644")

      expect(entity[:diff_refs].as_json).to eq({
        "base_sha" => "1b12f15a11fc6e62177bef08f47bc7b5ce50b141",
        "head_sha" => "b83d6e391c22777fca1ed3012fce84f633d7fed0",
        "start_sha" => "1b12f15a11fc6e62177bef08f47bc7b5ce50b141"
      })
    end
  end
end
