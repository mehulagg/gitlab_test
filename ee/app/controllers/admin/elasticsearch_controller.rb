# frozen_string_literal: true

class Admin::ElasticsearchController < Admin::ApplicationSettingsController
  extend ::Gitlab::Utils::Override

  before_action :set_application_setting, only: [:settings]

  def show
  end

  def settings
    perform_update if submitted?
  end

  private

  override :redirect_path
  def redirect_path
    admin_elasticsearch_settings_path
  end

  override :render_update_error
  def render_update_error
    render :settings
  end
end
