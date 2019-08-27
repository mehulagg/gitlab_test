# frozen_string_literal: true

class Admin::ElasticsearchController < Admin::ApplicationSettingsController
  extend ::Gitlab::Utils::Override

  before_action :set_application_setting, only: [:settings]

  def show
  end

  def settings
    perform_update if submitted?
  end

  # POST
  # Scheduling indexing jobs
  def enqueue_index
    if Gitlab::Elastic::Helper.index_exists?
      ::Elastic::IndexProjectsService.new.execute

      notice = _('Elasticsearch indexing started')
      queue_link = helpers.link_to(_('(check progress)'), sidekiq_path + '/queues/elastic_full_index')
      flash[:notice] = "#{notice} #{queue_link}".html_safe
    else
      flash[:warning] = _('Please create an index before enabling indexing')
    end
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
