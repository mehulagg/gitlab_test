# frozen_string_literal: true

# DiscussionAttributes is shared between NoteEntity and DiscussionEntity while
# we deprecate the latter. It specifies how discussion attributes are rendered,
# and relies on a `discussion` method being implemented.
module DiscussionAttributes
  extend ActiveSupport::Concern

  included do
    expose :active, if: -> (_, _) { diff_discussion? } do |_, _|
      active?
    end

    expose :expanded do |_, _|
      expanded?
    end

    expose :diff_discussion do |_, _|
      diff_discussion?
    end

    expose :individual_note do |_, _|
      individual_note?
    end

    expose :line_code, if: -> (_, _) { diff_discussion? }
    expose :position, if: -> (_, _) { non_legacy_diff_discussion? }
    expose :original_position, if: -> (_, _) { non_legacy_diff_discussion? }

    expose :diff_file, using: DiscussionDiffFileEntity, if: -> (_, _) { diff_discussion? }
    expose :truncated_diff_lines, using: DiffLineEntity, if: -> (_, _) { diff_discussion? && on_text? && (expanded? || render_truncated_diff_lines?) } do |_, _|
      truncated_diff_lines
    end

    expose :discussion_path do |_, _|
      discussion_path(discussion)
    end

    expose :resolve_path do |_, _|
      resolve_project_merge_request_discussion_path(discussion.project, discussion.noteable, discussion.id)
    end

    expose :resolve_with_issue_path, if: -> (_, _) { resolvable? } do |_, _|
      new_project_issue_path(discussion.project, merge_request_to_resolve_discussions_of: discussion.noteable.iid, discussion_to_resolve: discussion.id)
    end

    expose :truncated_diff_lines_path, if: -> (_, _) { !expanded? && !render_truncated_diff_lines? } do |_, _|
      project_merge_request_discussion_path(discussion.project, discussion.noteable, discussion)
    end
  end

  private

  delegate :active?, :diff_discussion?, :expanded?, :individual_note?, :on_text?, :resolvable?, :truncated_diff_lines, to: :discussion

  def non_legacy_diff_discussion?
    diff_discussion? && !discussion.legacy_diff_discussion?
  end

  def render_truncated_diff_lines?
    !!options[:render_truncated_diff_lines]
  end
end
