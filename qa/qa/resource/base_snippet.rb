module QA
  module Resource
    module BaseSnippet
      extend ActiveSupport::Concern

      included do
        attr_accessor :title, :description, :file_content, :visibility, :file_name
      end

      def initialize
        @title = 'New snippet title'
        @description = 'The snippet description'
        @visibility = 'Public'
        @file_content = 'The snippet content'
        @file_name = 'New snippet file name'
      end

      def fabricate!
        Page::Dashboard::Snippet::Index.perform(&:go_to_new_snippet_page)

        Page::Dashboard::Snippet::New.perform do |new_page|
          new_page.fill_title(title)
          new_page.fill_description(description)
          new_page.set_visibility(visibility)
          new_page.fill_file_name(file_name)
          new_page.fill_file_content(file_content)
          new_page.click_create_snippet_button
        end
      end

      def git_web_uri
        "#{web_url}.git"
      end
    end
  end
end
