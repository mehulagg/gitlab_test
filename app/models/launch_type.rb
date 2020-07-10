# frozen_string_literal: true

class LaunchType < ApplicationRecord
  belongs_to :project
  delegate :group, to: :project, allow_nil: true

  validates :project, presence: true
  validates :deploy_target_type, length: { maximum: 255 }, allow_blank: false
  validate :validate_deploy_target_type

  def deploy_target_type=(value)
    write_attribute(:deploy_target_type, value&.downcase&.strip)
  end

  private

  def validate_deploy_target_type
    # At this time there is no codified enumeration of deploy targets,
    # what documentation exists can be found at:
    # https://about.gitlab.com/stages-devops-lifecycle/deploy-targets/
  end
end
