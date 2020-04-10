# frozen_string_literal: true

module QA
  module Resource
    class ProjectSnippet < Base
      include BaseSnippet

      attribute :project do
        QA::Resource::Project.fabricate_via_api! do |project|
          project.name = 'project-with-snippet'
        end
      end

      def api_get_path
        "/projects/#{project.id}/snippets/#{id}"
      end
      alias_method :api_put_path, :api_get_path

      def api_post_path
        "/projects/#{project.id}/snippets"
      end

      def api_post_body
        {
          title: title,
          description: description,
          visibility: visibility.downcase,
          file_name: file_name,
          content: file_content
        }
      end
    end
  end
end
