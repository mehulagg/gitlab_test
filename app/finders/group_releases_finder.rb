# frozen_string_literal: true

class GroupReleasesFinder < ReleasesFinder
  attr_reader :group, :current_user, :params, :options

  def initialize(group:, current_user: nil, params: {}, options: {})
    @group = group
    @current_user = current_user
    @params = params
    @options = options
  end

  def execute
    releases = by_projects
    releases = by_tag(releases)
    releases = releases.preloaded if preload?
    releases.sorted
  end

  private

  def include_subgroups?
    options.fetch(:include_subgroups, false)
  end

  def preload?
    options.fetch(:preload, true)
  end

  def by_projects
    Release.where(project_id: accessible_projects).where.not(tag: nil) # rubocop:disable CodeReuse/ActiveRecord
  end

  def accessible_projects
    projects = if include_subgroups?
                 Project.for_group_and_its_subgroups(group)
               else
                 group.projects
               end

    projects.select { |project| Ability.allowed?(current_user, :read_project, project) }
  end
end
