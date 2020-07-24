# frozen_string_literal: true

module QA
  RSpec.describe 'Create' do
    context 'File management' do
      file_name = 'QA Test - File name'
      file_content = 'QA Test - File content'
      commit_message_for_create = 'QA Test - Create new file'

      before do
        Flow::Login.sign_in
      end

      it 'user creates a file via the Web' do
        Resource::File.fabricate_via_browser_ui! do |file|
          file.name = file_name
          file.content = file_content
          file.commit_message = commit_message_for_create
        end

        expect(page).to have_content('The file has been successfully created.')
        expect(page).to have_content(file_name)
        expect(page).to have_content(file_content)
        expect(page).to have_content(commit_message_for_create)
      end
    end
  end
end
