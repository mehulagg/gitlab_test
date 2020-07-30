# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'issues canonical link' do
  describe 'GET /:namespace/:project/-/issues/:id' do
    let(:epic)  { create(:epic) }
    let(:project) { create(:project, :public, group: epic.group) }
    let(:original_issue)   { create(:issue, project: project) }
    let(:canonical_url)    { epic_url(canonical_issue) }

    context 'when the issue was promoted' do
      it 'shows the canonical URL' do
        original_issue.promoted_to_epic = epic
        original_issue.save!

        visit(issue_path(original_issue))

        expect(page).to have_xpath("//link[@rel=\"canonical\" and @href=\"#{canonical_url}\"]", visible: false)
      end
    end
  end
end
