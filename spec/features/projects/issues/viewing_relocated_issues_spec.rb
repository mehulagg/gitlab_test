# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'issues canonical link' do
  describe 'GET /:namespace/:project/-/issues/:id' do
    let(:original_project) { create(:project, :public) }
    let(:original_issue)   { create(:issue, project: original_project) }
    let(:canonical_issue)  { create(:issue) }
    let(:canonical_url)    { issue_url(canonical_issue) }

    it "doesn't show the canonical URL" do
      visit(issue_path(original_issue))

      expect(page).not_to have_xpath('//link[@rel="canonical"]', visible: false)
    end

    context 'when the issue was moved' do
      it 'shows the canonical URL' do
        original_issue.moved_to = canonical_issue
        original_issue.save!

        visit(issue_path(original_issue))

        expect(page).to have_xpath("//link[@rel=\"canonical\" and @href=\"#{canonical_url}\"]", visible: false)
      end
    end

    context 'when the issue was duplicated' do
      it 'shows the canonical URL' do
        original_issue.duplicated_to = canonical_issue
        original_issue.save!

        visit(issue_path(original_issue))

        expect(page).to have_xpath("//link[@rel=\"canonical\" and @href=\"#{canonical_url}\"]", visible: false)
      end
    end
  end
end
