# frozen_string_literal: true

module QA
  RSpec.describe 'Create' do
    context 'File management' do
      let(:file) do
        Resource::File.fabricate_via_api! do |file|
          file.name = 'QA Test - File name'
          file.content = 'QA Test - File content'
          file.commit_message = 'QA Test - Create new file'
        end
      end

      before do
        Flow::Login.sign_in
        file.project.visit!
        find_link(file.api_response[:file_path]).click
      end

      it 'user edits a file via the Web' do
        updated_file_content = 'QA Test - Updated file content'
        commit_message_for_update = 'QA Test - Update file'

        Page::File::Show.perform(&:click_edit)

        Page::File::Form.act do
          remove_content
          add_content(updated_file_content)
          add_commit_message(commit_message_for_update)
          commit_changes
        end

        expect(page).to have_content('Your changes have been successfully committed.')
        expect(page).to have_content(updated_file_content)
        expect(page).to have_content(commit_message_for_update)
      end
    end
  end
end
