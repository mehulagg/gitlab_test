# frozen_string_literal: true

module QA
  context 'Create', :smoke do
    describe 'Snippet git operation' do
      let(:file_name) { 'foo.txt' }

      it 'allows cloning and pushing' do
        Flow::Login.sign_in

        clone_and_push_snippet(personal_snippet(visibility: 'Public'))
        clone_and_push_snippet(personal_snippet(visibility: 'Internal'))
        clone_and_push_snippet(project_snippet(visibility: 'Public'))
        clone_and_push_snippet(project_snippet(visibility: 'Internal'))
      end

      private

      def personal_snippet(visibility:)
        Resource::PersonalSnippet.fabricate! do |snippet|
          snippet.visibility = visibility
          snippet.file_name = file_name
        end
      end

      def project_snippet(visibility:)
        Resource::ProjectSnippet.fabricate! do |snippet|
          snippet.visibility = visibility
          snippet.file_name = file_name
        end
      end

      def clone_and_push_snippet(snippet)
        Git::Repository.perform do |repository|
          repository.uri = snippet.git_web_uri
          repository.use_default_credentials

          repository.clone
          repository.commit_file(file_name, 'xyz', 'Updated the file')
          result = repository.push_changes

          expect(result).to include('master -> master')
          expect(result).not_to include('failed')
        end
      end
    end
  end
end
