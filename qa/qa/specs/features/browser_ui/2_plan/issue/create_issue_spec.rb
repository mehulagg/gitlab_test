# frozen_string_literal: true

module QA
  context 'Plan', :smoke do
    describe 'Issue creation' do
      before do
        Flow::Login.sign_in
      end

      it 'creates an issue', :reliable do
        issue = Resource::Issue.fabricate_via_browser_ui!

        Page::Project::Menu.perform(&:click_issues)

        Page::Project::Issue::Index.perform do |index|
          expect(index).to have_issue(issue)
        end
      end

      context 'when using attachments in comments' do
        let(:sample_file) { 'sample_file.jpg' }

        before do
          Resource::Issue.fabricate_via_api!.visit!
        end

        it 'comments on an issue with an attachment' do
          Page::Project::Issue::Show.perform do |show|
            show.comment("See attachment ![sample_file](#{sample_file})")

            expect(show.noteable_note_item.find("img[src$='#{sample_file}']")).to be_visible
          end
        end
      end
    end
  end
end
