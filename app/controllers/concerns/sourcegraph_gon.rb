# frozen_string_literal: true

module SourcegraphGon
  extend ActiveSupport::Concern

  included do
    before_action :push_sourcegraph_gon, if: :html_request?
  end

  private

  def push_sourcegraph_gon
    return unless enabled?

    gon.push({
      sourcegraph: { url: Gitlab::CurrentSettings.sourcegraph_url }
    })
  end

  def enabled?
    Gitlab::CurrentSettings.sourcegraph_enabled && enabled_for_project? && current_user&.sourcegraph_enabled
  end

  def enabled_for_project?
    return false unless project && Gitlab::Sourcegraph.feature_enabled?(project)
    return project.public? if Gitlab::CurrentSettings.sourcegraph_public_only

    true
  end
end
