# frozen_string_literal: true

module QA
  context 'Create', :smoke do
    describe 'Snippet git operation' do
      let(:file_name) { 'foo.txt' }

      it 'handles personal snippet' do
        Flow::Login.sign_in

        clone_and_push_snippet(personal_snippet(visibility: 'Public'))
        clone_and_push_snippet(personal_snippet(visibility: 'Internal'))
      end

      private

      def personal_snippet(visibility:)
        Resource::Snippet.fabricate! do |snippet|
          snippet.visibility = visibility
          snippet.file_name = file_name
        end
      end

      def clone_and_push_snippet(snippet)
        # TODO: fetch git path when UI provides them
        clone_url = "#{snippet.web_url}.git"

        Git::Repository.perform do |repository|
          repository.uri = clone_url
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
