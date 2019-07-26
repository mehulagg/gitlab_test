# frozen_string_literal: true

module ResolveableNoteEntity
  extend ActiveSupport::Concern

  included do
    expose :resolved?, as: :resolved
    expose :resolvable?, as: :resolvable
    expose :resolved_by_push?, as: :resolved_by_push
    expose :resolved_by, using: NoteUserEntity
    expose :resolved_at
  end
end
