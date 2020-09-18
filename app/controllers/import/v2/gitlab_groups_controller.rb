# frozen_string_literal: true

class Import::V2::GitlabGroupsController < Import::BaseController
  before_action :ensure_group_import_enabled

  def import_params
    params.permit(:url, :token)
  end

  def ensure_group_import_enabled
    render_404 unless Feature.enabled?(:group_import_v2)
  end
end
