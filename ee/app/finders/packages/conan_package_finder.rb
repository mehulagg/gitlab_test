# frozen_string_literal: true

module Packages
  class ConanPackageFinder
    attr_reader :current_user, :query, :project, :recipe

    def initialize(current_user, options)
      @current_user = current_user
      @project = project
      @query = options[:query]
      @project = options[:project]
      @recipe = options[:recipe]
    end

    def execute
      return unless project

      project.packages.with_name(recipe).order_created.last
    end

    def api_search
      return unless query

      packages_for_current_user.with_name_like(query).order_name_asc
    end

    private

    def packages
      Packages::Package.conan
    end

    def packages_for_current_user
      packages.for_projects(projects_visible_to_current_user)
    end

    def projects_visible_to_current_user
      ::Project.public_or_visible_to_user(current_user)
    end
  end
end
