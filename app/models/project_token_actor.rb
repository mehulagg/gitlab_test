# frozen_string_literal: true

class ProjectTokenActor
  include PolicyActor
  include Referable

  attr_reader :id, :username, :project_token
  def initialize(project_token:)
    @username = @id = SecureRandom.hex
    @project_token = project_token
  end

  def has_access_to?(requested_project)
    project_token.project == requested_project
  end
end
