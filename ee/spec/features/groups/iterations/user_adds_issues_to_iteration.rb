# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Iterations list', :js do
  let(:now) { Time.now }
  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, group: group) }
  let_it_be(:issue) { create(:issue, project: project) }
  let_it_be(:user) { create(:user) }
  let!(:started_iteration) { create(:iteration, :skip_future_date_validation, title: 'Current iteration', group: group, start_date: now - 1.day, due_date: now) }
  let!(:upcoming_iteration) { create(:iteration, title: 'Future iteration', group: group, start_date: now + 1.day, due_date: now + 2.days) }
  let!(:closed_iteration) { create(:closed_iteration, :skip_future_date_validation, title: 'Closed iteration', group: group, start_date: now - 3.days, due_date: now - 2.days) }

  context 'as user' do
    before do
      stub_licensed_features(iterations: true)
      stub_feature_flags(group_iterations: true)
      group.add_developer(user)
      sign_in(user)
      visit issue_path(issue)
    end

    it 'allows assigning only to open iterations' do
      live_debug

      expect(page).to have_link('New iteration', href: new_group_iteration_path(group))
    end
  end
end
