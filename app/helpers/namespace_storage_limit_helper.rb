# frozen_string_literal: true

module NamespaceStorageLimitHelper
  def alert_icon(alert_level)
    case alert_level
    when nil
      ''
    when :info
      'information-o'
    when :warning
      'warning'
    else
      'error'
    end
  end

  def alert_class(alert_level)
    case alert_level
    when nil
      ''
    when :info
      'gl-alert-info'
    when :warning
      'gl-alert-warning'
    else
      'gl-alert-danger'
    end
  end
end
