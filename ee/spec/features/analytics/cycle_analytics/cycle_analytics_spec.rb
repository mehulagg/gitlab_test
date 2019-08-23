# frozen_string_literal: true
require 'spec_helper'

describe 'Group Cycle Analytics', :js do
  let!(:user) { create(:user) }
  let!(:group) { create(:group, name: "CA-test-group") }
  let!(:project) { create(:project, :repository, namespace: group, group: group, name: "Cool fun project") }

  3.times do |i|
    let!(:issue2) { create(:issue, title: "New Issue #{i}", project: project, created_at: 2.days.ago) }
  end

  before do
    stub_licensed_features(cycle_analytics_for_groups: true)
    group.add_owner(user)
    project.add_maintainer(user)

    sign_in(user)

    visit analytics_cycle_analytics_path
  end

  it 'displays an empty state before a group is selected' do
    element = page.find('.row.empty-state')

    expect(element).to have_content("Cycle Analytics can help you determine your team’s velocity")
    expect(element.find('.svg-content img')['src']).to have_content('illustrations/analytics/cycle-analytics-empty-chart')
  end

  context 'displays correct fields after group selection' do
    before do
      dropdown = page.find('.dropdown-groups')
      dropdown.click
      dropdown.find('a').click
    end

    it 'hides the empty state' do
      expect(page).to have_selector('.row.empty-state', visible: false)
    end

    it 'shows the projects filter' do
      expect(page).to have_selector('.dropdown-projects', visible: true)
    end

    it 'shows the date filter' do
      expect(page).to have_selector('.js-timeframe-filter', visible: true)
    end

    it 'smoke test' do
      expect(page).not_to have_selector('.cycle-analytics', visible: true)
      expect(page).to have_selector('#cycle-analytics', visible: true)
    end
  end

  # TODO: Followup should have tests for stub_licensed_features(cycle_analytics_for_groups: false)
  def select_group
    dropdown = page.find('.dropdown-groups')
    dropdown.click
    dropdown.find('a').click
  end

  def select_project
    select_group

    dropdown = page.find('.dropdown-projects')
    dropdown.click
    dropdown.find('a').click
    dropdown.click
  end

  context 'with cycle_analytics_app cookie set', :js do
    context 'with minimal data' do
      before do
        set_cookie('cycle_analytics_app', 'true')

        group.add_owner(user)
        project.add_maintainer(user)

        sign_in(user)

        visit analytics_cycle_analytics_path
        select_group
      end

      it 'smoke test' do
        expect(page).to have_selector('.cycle-analytics', visible: true)
        expect(page).not_to have_selector('#cycle-analytics', visible: true)
      end

      it 'displays empty text' do
        [
          'Cycle Analytics can help you determine your team’s velocity',
          'Start by choosing a group to see how your team is spending time. You can then drill down to the project level.'
        ].each do |content|
          expect(page).to have_content(content)
        end
      end

      context 'summary table', :js do
        it 'will display recent activity' do
          page.within(find('.js-summary-table')) do
            expect(page).to have_selector('.card-header')
            expect(page).to have_content('Recent Activity')
          end
        end

        it 'displays the number of issues' do
          expect(page).to have_content('New Issues')

          issue_count = find(".card .header", match: :first)
          expect(issue_count).to have_content('3')
        end

        it 'displays the number of deploys' do
          expect(page).to have_content('Deploys')

          deploys_count = page.all(".card .header").last
          expect(deploys_count).to have_content('-')
        end
      end

      # These should probably move to more unit / integration type tests
      # should have a group set and some data
      context 'stage panel' do
        it 'displays the stage table headers' do
          expect(page).to have_selector('.stage-header', visible: true)
          expect(page).to have_selector('.median-header', visible: true)
          expect(page).to have_selector('.event-header', visible: true)
          expect(page).to have_selector('.total-time-header', visible: true)
        end
      end

      context 'stage nav' do
        it 'displays the list of stages' do

          expect(page).to have_selector('.stage-nav', visible: true)
        end

        it 'displays the default list of stages' do
          stage_nav = page.find('.stage-nav')

          %w[Issue Plan Code Test Review Staging Production].each do |item|
            expect(stage_nav).to have_content(item)
          end
        end
      end
    end

    context 'with lots of data' do
      15.times do |i|
        create(:issue, title: "Issue #{i}", project: project, created_at: 2.days.ago)
        create(:merge_request, source_project: project, created_at: 2.days.ago)
      end

      it 'will have data' do
      end
    end
  end
end
