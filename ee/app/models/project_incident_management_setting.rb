# frozen_string_literal: true

class ProjectIncidentManagementSetting < ApplicationRecord
  belongs_to :project

  validate :validate_issue_template_path, if: :create_issue?

  def available_issue_templates
    Gitlab::Template::IssueTemplate.all(project)
  end

  private

  def validate_issue_template_path
    return unless issue_template_key_changed?

    Gitlab::Template::IssueTemplate.find(issue_template_key, project)
  rescue Gitlab::Template::Finders::RepoTemplateFinder::FileNotFoundError
    errors.add(:issue_template_key, 'not found')
  end
end
