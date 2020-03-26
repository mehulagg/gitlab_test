# frozen_string_literal: true

require "spec_helper"

describe Gitlab::Diff::Formatters::MultiTextFormatter do
  let!(:base) do
    {
      base_sha: 123,
      start_sha: 456,
      head_sha: 789,
      old_path: "old_path.txt",
      new_path: "new_path.txt",
      position_type: "multi_text"
    }
  end

  let!(:complete) do
    base.merge(old_start_line: 1, new_start_line: 2, old_end_line: 2, new_end_line: 4)
  end

  it_behaves_like "position formatter" do
    let(:base_attrs) { base }
    let(:attrs) { complete }

    let(:key) do
      [123, 456, 789, Digest::SHA1.hexdigest(formatter.old_path), Digest::SHA1.hexdigest(formatter.new_path), 1, 2, 2, 4]
    end
  end

  # Specific text formatter examples
  let!(:formatter) { described_class.new(attrs) }

  describe "#start_line_age" do
    subject { formatter.start_line_age }

    context "when there is only new_start_line" do
      let(:attrs) { base.merge(new_start_line: 1) }

      it { is_expected.to eq("new") }
    end

    context "when there is only old_start_line" do
      let(:attrs) { base.merge(old_start_line: 1) }

      it { is_expected.to eq("old") }
    end
  end

  describe "#end_line_age" do
    subject { formatter.end_line_age }

    context "when there is only new_end_line" do
      let(:attrs) { base.merge(new_end_line: 1) }

      it { is_expected.to eq("new") }
    end

    context "when there is only old_end_line" do
      let(:attrs) { base.merge(old_end_line: 1) }

      it { is_expected.to eq("old") }
    end
  end
end
