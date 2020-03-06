# frozen_string_literal: true

class SyntheticNote < Note
  attr_accessor :resource_parent, :event

  self.abstract_class = true

  def self.note_attributes(action, event, resource = nil, resource_parent = nil)
    resource ||= event.resource

    attrs = {
        system: true,
        author: event.user,
        created_at: event.created_at,
        discussion_id: event.discussion_id,
        noteable: resource,
        event: event,
        system_note_metadata: ::SystemNoteMetadata.new(action: action),
        resource_parent: resource_parent
    }

    if resource_parent.is_a?(Project)
      attrs[:project_id] = resource_parent.id
    end

    attrs
  end

  def project
    resource_parent if resource_parent.is_a?(Project)
  end

  def group
    resource_parent if resource_parent.is_a?(Group)
  end

  def note
    @note ||= note_text
  end

  private

  def note_text(html: false)
    raise NotImplementedError
  end

  def note_html
    raise NotImplementedError
  end
end
