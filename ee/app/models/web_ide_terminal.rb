# frozen_string_literal: true

class WebIdeTerminal
  include ::Gitlab::Routing

  attr_reader :build, :project

  delegate :id, :status, to: :build

  def initialize(build)
    @build = build
    @project = build.project
  end

  def show_path
    web_ide_terminal_route_generator(:show)
  end

  def retry_path
    web_ide_terminal_route_generator(:retry)
  end

  def cancel_path
    web_ide_terminal_route_generator(:cancel)
  end

  def terminal_path
    terminal_project_job_url(project, build, format: :ws)
  end

  private

  def web_ide_terminal_route_generator(action)
    url_for(action: action,
            controller: 'projects/web_ide_terminals',
            namespace_id: project.namespace.to_param,
            project_id: project.to_param,
            id: build.id)
  end
end
