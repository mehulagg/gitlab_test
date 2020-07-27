# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Epic in issue sidebar', :js do
  let(:user) { create(:user) }
  let(:group) { create(:group, :public) }
  let(:epic1) { create(:epic, group: group, title: 'Foo') }
  let!(:epic2) { create(:epic, group: group, title: 'Bar') }
  let!(:epic3) { create(:epic, group: group, title: 'Baz') }
  let(:project) { create(:project, :public, group: group) }
  let(:issue) { create(:issue, project: project) }
  let!(:epic_issue) { create(:epic_issue, epic: epic1, issue: issue) }

  shared_examples 'epic in issue sidebar' do
    context 'projects within a group' do
      before do
        group.add_owner(user)
        visit project_issue_path(project, issue)
      end

      it 'shows epic in issue sidebar' do
        expect(page.find('.js-epic-block .value')).to have_content(epic1.title)
      end
    end
  end

  context 'when epics available' do
    before do
      stub_licensed_features(epics: true)

      sign_in(user)
      visit project_issue_path(project, issue)
      wait_for_requests
    end

    context 'with namespaced plans' do
      before do
        stub_application_setting(check_namespace_plan: true)
      end

      context 'group has license' do
        before do
          create(:gitlab_subscription, :gold, namespace: group)
        end

        it_behaves_like 'epic in issue sidebar'
      end
    end
  end
end
