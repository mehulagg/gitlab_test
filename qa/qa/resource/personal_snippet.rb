# frozen_string_literal: true

module QA
  module Resource
    class PersonalSnippet < Base
      include BaseSnippet

      def api_get_path
        "/snippets/#{id}"
      end
      alias_method :api_put_path, :api_get_path

      def api_post_path
        "/snippets"
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

      def api_put_body
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
