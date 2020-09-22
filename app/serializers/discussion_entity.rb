# frozen_string_literal: true

class DiscussionEntity < Grape::Entity
  include RequestAwareEntity
  include NotesHelper
  include DiscussionAttributes

  expose :id, :reply_id
  expose :project_id

  expose :notes do |discussion, opts|
    request.note_entity.represent(discussion.notes, opts)
  end

  expose :positions, if: -> (d, _) { display_merge_ref_discussions?(d) } do |discussion|
    discussion.diff_note_positions.map(&:position)
  end

  expose :line_codes, if: -> (d, _) { display_merge_ref_discussions?(d) } do |discussion|
    discussion.diff_note_positions.map(&:line_code)
  end

  expose :resolvable?, as: :resolvable
  expose :resolved?, as: :resolved
  expose :resolved_by_push?, as: :resolved_by_push
  expose :resolved_by, using: NoteUserEntity
  expose :resolved_at

  expose :for_commit?, as: :for_commit
  expose :commit_id
  expose :confidential?, as: :confidential

  private

  def discussion
    object
  end

  def current_user
    request.current_user
  end

  def display_merge_ref_discussions?(discussion)
    return unless discussion.diff_discussion?
    return if discussion.legacy_diff_discussion?

    Feature.enabled?(:merge_ref_head_comments, discussion.project, default_enabled: true)
  end
end
