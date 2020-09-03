# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Group value stream analytics filters and data', :js do
  let_it_be(:group) { create(:group) }
  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project, :repository, namespace: group, group: group, name: 'Cool fun project') }
  let_it_be(:sub_group) { create(:group, name: 'CA-sub-group', parent: group) }

  let(:milestone) { create(:milestone, project: project) }
  let(:mr) { create_merge_request_closing_issue(user, project, issue, commit_message: "References #{issue.to_reference}") }
  let(:pipeline) { create(:ci_empty_pipeline, status: 'created', project: project, ref: mr.source_branch, sha: mr.source_branch_sha, head_pipeline_of: mr) }

  stage_nav_selector = '.stage-nav'
  path_nav_selector = '.js-path-navigation'
  card_metric_selector = '.js-recent-activity .js-metric-card-item'
  new_issues_count = 3

  new_issues_count.times do |i|
    let_it_be("issue_#{i}".to_sym) { create(:issue, title: "New Issue #{i}", project: project, created_at: 2.days.ago) }
  end

  def wait_for_stages_to_load
    expect(page).to have_selector '.js-stage-table'
  end

  # TODO: figure out how to build url from object
  def select_group(target_group = group)
    visit group_analytics_cycle_analytics_path(target_group)

    wait_for_stages_to_load
  end

  before do
    stub_licensed_features(cycle_analytics_for_groups: true, type_of_work_analytics: true)

    group.add_owner(user)
    project.add_maintainer(user)

    sign_in(user)
  end

  shared_examples 'empty state' do
    it 'displays an empty state' do
      element = page.find('.row.empty-state')

      expect(element).to have_content(_("We don't have enough data to show this stage."))
      expect(element.find('.svg-content img')['src']).to have_content('illustrations/analytics/cycle-analytics-empty-chart')
    end
  end

  shared_examples 'no group available' do
    it 'displays empty text' do
      [
        'Value Stream Analytics can help you determine your team’s velocity',
        'Start by choosing a group to see how your team is spending time. You can then drill down to the project level.'
      ].each do |content|
        expect(page).to have_content(content)
      end
    end
  end

  shared_examples 'has overview metrics', :js do
    before do
      wait_for_requests
    end

    it 'will display activity metrics' do
      page.within(find('.js-recent-activity')) do
        expect(page).to have_content(_('Recent Activity'))
        expect(page).to have_content(_('Time'))
      end
    end

    it 'displays the recent activity' do
      deploys_count = page.all(card_metric_selector)[3]

      expect(deploys_count).to have_content(n_('Deploy', 'Deploys', 0))
      expect(deploys_count).to have_content('-')

      deployment_frequency = page.all(card_metric_selector).last

      expect(deployment_frequency).to have_content(_('Deployment Frequency'))
      expect(deployment_frequency).to have_content('-')

      issue_count = page.all(card_metric_selector)[2]

      expect(issue_count).to have_content(n_('New Issue', 'New Issues', 3))
      expect(issue_count).to have_content(new_issues_count)
    end

    it 'displays time metrics' do
      lead_time = page.all(card_metric_selector).first

      expect(lead_time).to have_content(_('Lead Time'))
      expect(lead_time).to have_content('-')

      cycle_time = page.all(card_metric_selector)[1]

      expect(cycle_time).to have_content(_('Cycle Time'))
      expect(cycle_time).to have_content('-')
    end
  end

  shared_examples 'group value stream analytics' do |selected_group|
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
        expect(page).to have_selector(stage_nav_selector, visible: true)
      end

      it 'displays the default list of stages' do
        stage_nav = page.find(stage_nav_selector)

        %w[Issue Plan Code Test Review Staging Total].each do |item|
          string_id = "CycleAnalytics|#{item}"
          expect(stage_nav).to have_content(s_(string_id))
        end
      end
    end

    context 'path nav' do
      before do
        stub_feature_flags(value_stream_analytics_path_navigation: true)

        select_group(selected_group)
      end

      it 'displays the default list of stages' do
        path_nav = page.find(path_nav_selector)

        %w[Issue Plan Code Test Review Staging Overview].each do |item|
          string_id = "CycleAnalytics|#{item}"
          expect(path_nav).to have_content(s_(string_id))
        end
      end
    end
  end

  context 'without valid query parameters set' do
    context 'with created_after date > created_before date' do
      before do
        visit "#{group_analytics_cycle_analytics_path(group)}?created_after=2019-12-31&created_before=2019-11-01"
      end

      it_behaves_like 'no group available'
    end

    context 'with fake parameters' do
      before do
        visit "#{group_analytics_cycle_analytics_path(group)}?beans=not-cool"
      end

      it_behaves_like 'empty state'
    end
  end

  context 'with valid query parameters set' do
    projects_dropdown = '.js-projects-dropdown-filter'

    context 'with project_ids set' do
      before do
        visit "#{group_analytics_cycle_analytics_path(group)}?project_ids[]=#{project.id}"
      end

      it 'has the projects dropdown prepopulated' do
        element = page.find(projects_dropdown)

        expect(element).to have_content project.name
      end
    end

    context 'with created_before and created_after set' do
      date_range = '.js-daterange-picker'

      before do
        visit "#{group_analytics_cycle_analytics_path(group)}?created_before=2019-12-31&created_after=2019-11-01"
      end

      it 'has the date range prepopulated' do
        element = page.find(date_range)

        expect(element.find('.js-daterange-picker-from input').value).to eq '2019-11-01'
        expect(element.find('.js-daterange-picker-to input').value).to eq '2019-12-31'
      end
    end
  end

  context 'with a group' do
    before do
      select_group
    end

    it_behaves_like 'group value stream analytics', group

    it_behaves_like 'has overview metrics'
  end

  context 'with a sub group' do
    before do
      select_group(sub_group)
    end

    it_behaves_like 'group value stream analytics', sub_group

    it_behaves_like 'has overview metrics'
  end
end
