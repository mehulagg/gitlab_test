# frozen_string_literal: true

class WebIdeTerminalSerializer < BaseSerializer
  entity WebIdeTerminalEntity

  def represent(resource, opts = {})
    resource = WebIdeTerminal.new(params[:current_user], resource) if resource.is_a?(Ci::Build)

    super
  end
end
