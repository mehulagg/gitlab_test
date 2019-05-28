# frozen_string_literal: true

class WebIdeTerminal
  include ::Gitlab::Routing
  DOMAIN_KEY = "services".freeze

  attr_reader :build, :project, :user

  def initialize(user, build)
    @build = build
    @project = build.project
    @user = user
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
    terminal_project_job_path(project, build, format: :ws)
  end

  # The proxy url goes through GitLab Pages, therefore we build the url
  # using the user's username, a special prefix, the build id, and the rest
  # of the Pages domain
  def proxy_path
    Addressable::URI.parse(Gitlab.config.pages.url).tap do |u|
      u.host = [user.username, DOMAIN_KEY, build.id, u.host].join('.')
    end.to_s
  end

  def proxy_websocket_path
    proxy_project_job_path(project, build, format: :ws)
  end

  private

  def web_ide_terminal_route_generator(action, options = {})
    options.reverse_merge!(action: action,
                           controller: 'projects/web_ide_terminals',
                           namespace_id: project.namespace.to_param,
                           project_id: project.to_param,
                           id: build.id,
                           only_path: true)

    url_for(options)
  end
end
