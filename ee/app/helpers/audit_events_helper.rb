# frozen_string_literal: true

module AuditEventsHelper
  def human_text(details)
    ::Audit::Details.humanize(details)
  end
end
