# frozen_string_literal: true

module QA
  RSpec.describe 'Create' do
    context 'File management' do
      before do
        Resource::File.fabricate_via_api! do |file|
          file.name = 'QA Test - File name'
          file.content = 'QA Test - File content'
          file.commit_message = 'QA Test - Create new file'
        end
        Flow::Login.sign_in
      end

      it 'user deletes a file via the Web' do
        commit_message_for_delete = 'QA Test - Delete file'

        Page::File::Show.act do
          click_delete
          add_commit_message(commit_message_for_delete)
          click_delete_file
        end

        expect(page).to have_content('The file has been successfully deleted.')
        expect(page).to have_content(commit_message_for_delete)
        expect(page).to have_no_content(file_name)
      end
    end
  end
end
