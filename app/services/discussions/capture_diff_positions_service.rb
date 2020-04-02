# frozen_string_literal: true

module Discussions
  class CaptureDiffPositionsService < BaseService
    def execute(merge_request, params)
      old_diff_refs, new_diff_refs = build_diff_refs(merge_request, params)

      return unless old_diff_refs && new_diff_refs

      discussions, paths = build_discussions(merge_request, old_diff_refs)

      return if discussions.empty?

      tracer = build_tracer(old_diff_refs, new_diff_refs, paths)

      discussions.each do |discussion|
        capture_position_for_discussion(tracer, discussion)
      end
    end

    private

    def capture_position_for_discussion(tracer, discussion)
      result = tracer.trace(discussion.position)
      return unless result

      position = result[:position]

      # Currently position data is copied across all notes of a discussion
      # It makes sense to store a position only for the first note instead
      # Within the newly introduced table we can start doing just that
      note = discussion.notes.first
      note.diff_note_positions.create_or_update_by(:merge_ref_head,
        position: position,
        line_code: position.line_code(project.repository))
    end

    def build_diff_refs(merge_request, params)
      return unless params
      return unless merge_request.has_complete_diff_refs?

      old_diff_refs = merge_request.diff_refs
      new_diff_refs = Gitlab::Diff::DiffRefs.new(
        base_sha: params[:source_id],
        start_sha: params[:target_id],
        head_sha: params[:commit_id])

      return if new_diff_refs == old_diff_refs

      [old_diff_refs, new_diff_refs]
    end

    def build_discussions(merge_request, diff_refs)
      active_diff_discussions = merge_request.notes.new_diff_notes.discussions.select do |discussion|
        discussion.active?(diff_refs)
      end
      paths = active_diff_discussions.flat_map { |n| n.diff_file.paths }.uniq

      [active_diff_discussions, paths]
    end

    def build_tracer(old_diff_refs, new_diff_refs, paths)
      Gitlab::Diff::PositionTracer.new(
        project: project,
        old_diff_refs: old_diff_refs,
        new_diff_refs: new_diff_refs,
        paths: paths)
    end
  end
end
