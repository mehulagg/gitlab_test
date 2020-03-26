# frozen_string_literal: true

class DiffNotePosition < ApplicationRecord
  belongs_to :note

  enum position_type: {
    text: 0,
    image: 1
  }

  enum type: {
    merge_ref_head: 0
  }

  def position
    Gitlab::Diff::Position.new(
      old_path: old_path,
      new_path: new_path,
      old_line: old_line,
      new_line: new_line,
      position_type: position_type,
      diff_refs: Gitlab::Diff::DiffRefs.new(
        base_sha: base_sha,
        start_sha: start_sha,
        head_sha: head_sha
      )
    )
  end

  def position=(position)
    assign_attributes(position.to_h)
  end
end
