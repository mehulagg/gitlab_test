# frozen_string_literal: true

module Gitlab
  module RepoPath
    NotFoundError = Class.new(StandardError)

    def self.parse(path)
      repo_path = path.delete_prefix('/').delete_suffix('.git')
      redirected_path = nil

      # Detect the repo type based on the path, the first one tried is the project
      # type, which does not have a suffix.
      Gitlab::GlRepository.types.each do |_name, type|
        # If the project path does not end with the defined suffix, try the next
        # type.
        # We'll always try to find a project with an empty suffix (for the
        # `Gitlab::GlRepository::PROJECT` type.
        next unless type.valid?(repo_path)

        # Removing the suffix (.wiki, .design, ...) from the project path
        full_path = repo_path.chomp(type.path_suffix)
        container, project, redirected_path = find_container(type, full_path)

        return [container, project, type, redirected_path] if container
      end

      # When a project did not exist, the parsed repo_type would be empty.
      # In that case, we want to continue with a regular project repository. As we
      # could create the project if the user pushing is allowed to do so.
      [nil, nil, Gitlab::GlRepository.default_type, nil]
    end

    def self.find_container(type, full_path)
      return [nil, nil, nil] if full_path.blank?

      container =
        if type.snippet?
          find_snippet(full_path)
        elsif type.wiki?
          find_wiki(full_path)
        else
          find_project(full_path)
        end

      project = container&.try(:project)
      redirected_path = redirected?(project, full_path) ? full_path : nil

      [container, project, redirected_path]
    end

    def self.find_project(project_path)
      Project.find_by_full_path(project_path, follow_redirects: true)
    end

    # Snippet_path can be either:
    # - snippets/1
    # - h5bp/html5-boilerplate/snippets/53
    def self.find_snippet(snippet_path)
      snippet_id, project_path = extract_snippet_info(snippet_path)
      return unless snippet_id

      if project_path
        return unless project = find_project(project_path)
      end

      Snippet.find_by_id_and_project(id: snippet_id, project: project)
    end

    # Wiki path can be either:
    # - namespace/project.wiki
    # - group/subgroup/project.wiki
    # - group.wiki
    # - group/subgroup.wiki
    def self.find_wiki(wiki_path)
      container = Routable.find_by_full_path(wiki_path, follow_redirects: true)
      container&.try(:wiki)
    end

    def self.redirected?(container, container_path)
      container && container.full_path.casecmp(container_path) != 0
    end

    def self.extract_snippet_info(snippet_path)
      path_segments = snippet_path.split('/')
      snippet_id = path_segments.pop
      path_segments.pop # Remove 'snippets' from path
      project_path = File.join(path_segments)

      [snippet_id, project_path]
    end
  end
end

Gitlab::RepoPath.singleton_class.prepend_if_ee('EE::Gitlab::RepoPath::ClassMethods')
