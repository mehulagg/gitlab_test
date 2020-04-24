# frozen_string_literal: true

class JiraSettings < ApplicationRecord
  belongs_to :project

  scope :project_level, -> { where.not(project_id: nil) }
  scope :instance_level, -> { find_by(instance: true) }

  after_save :update_cache_table
  after_destroy :remove_from_cache_table

  def self.encryption_options
    {
      key: Settings.attr_encrypted_db_key_base_32,
      encode: true,
      mode: :per_attribute_iv,
      algorithm: 'aes-256-gcm'
    }
  end

  attr_encrypted :url, encryption_options
  attr_encrypted :api_url, encryption_options
  attr_encrypted :username, encryption_options
  attr_encrypted :password, encryption_options

  def self.generate_cache_table
    self.find_each do |jira_settings|
      jira_settings.generate_cache_services
    end
  end

  def title
    'Jira'
  end

  def activated?
    !!active
  end

  private

  def update_cache_table
    if instance?
      self.class.generate_cache_table
    else
      generate_cache_services
    end
  end

  def project_service_attributes
    {
      url: url,
      username: username,
      password: password,
      active: active,
      api_url: api_url,
      jira_issue_transition_id: jira_issue_transition_identifier,
      merge_requests_events: merge_requests_events,
      commit_events: commit_events,
      comment_on_event_enabled: comment_on_event_enabled
    }
  end

  def generate_cache_services
    if instance?
      Project.where.not(id: self.class.project_level.pluck(:project_id)).find_each do |project|
        project.jira_service.delete
        project.create_jira_service(project_service_attributes)
      end
    else
      project.jira_service.delete if project.jira_service
      project.create_jira_service(project_service_attributes)
    end
  end

  # rubocop:disable CodeReuse/ServiceClass
  def remove_from_cache_table
    if instance?
      JiraService.where.not(id: self.class.project_level.pluck(:project_id)).delete_all
      self.class.project_level.each do |project_level_setting|
        project_level_setting.generate_cache_services
      end
    else
      JiraService.find_by(project_id: project_id).delete
      instance_level_setting = self.class.instance_level
      JiraService.create(instance_level_setting.project_service_attributes.merge(project_id: project_id)) if instance_level_setting.present?
    end
  end
  # rubocop:enable CodeReuse/ServiceClass
end
