# frozen_string_literal: true
require 'spec_helper'

RSpec.describe 'Group Value Stream Analytics', :js do
  include DragTo

  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group, name: 'CA-test-group') }
  let_it_be(:sub_group) { create(:group, name: 'CA-sub-group', parent: group) }
  let_it_be(:group2) { create(:group, name: 'CA-bad-test-group') }
  let_it_be(:project) { create(:project, :repository, namespace: group, group: group, name: 'Cool fun project') }
  let_it_be(:group_label1) { create(:group_label, group: group) }
  let_it_be(:group_label2) { create(:group_label, group: group) }
  let_it_be(:label) { create(:group_label, group: group2) }
  let_it_be(:sub_group_label1) { create(:group_label, group: sub_group) }
  let_it_be(:sub_group_label2) { create(:group_label, group: sub_group) }

  let(:milestone) { create(:milestone, project: project) }
  let(:mr) { create_merge_request_closing_issue(user, project, issue, commit_message: "References #{issue.to_reference}") }
  let(:pipeline) { create(:ci_empty_pipeline, status: 'created', project: project, ref: mr.source_branch, sha: mr.source_branch_sha, head_pipeline_of: mr) }

  stage_nav_selector = '.stage-nav'
  path_nav_selector = '.js-path-navigation'
  filter_bar_selector = '.js-filter-bar'
  duration_stage_selector = '.js-dropdown-stages'
  value_stream_selector = '[data-testid="dropdown-value-streams"]'

  3.times do |i|
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

  def select_project
    select_group

    dropdown = page.find('.dropdown-projects')
    dropdown.click
    dropdown.find('a').click
    dropdown.click
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

  before do
    stub_licensed_features(cycle_analytics_for_groups: true, type_of_work_analytics: true)

    group.add_owner(user)
    project.add_maintainer(user)

    sign_in(user)
  end

  it_behaves_like 'empty state'

  context 'deep linked url parameters' do
    projects_dropdown = '.js-projects-dropdown-filter'

    context 'without valid query parameters set' do
      context 'with created_after date > created_before date' do
        before do
          visit "#{group_analytics_cycle_analytics_path(group)}?created_after=2019-12-31&created_before=2019-11-01"
        end

        it_behaves_like 'no group available'
      end

      context 'with fake parameters' do
        # TODO: problematic
        before do
          visit "#{group_analytics_cycle_analytics_path(group)}?beans=not-cool"
        end

        it_behaves_like 'empty state'
      end
    end

    context 'with valid query parameters set' do
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
  end

  context 'displays correct fields after group selection' do
    before do
      select_group
    end

    it 'hides the empty state' do
      expect(page).to have_selector('.row.empty-state', visible: false)
    end

    it 'shows the projects filter' do
      expect(page).to have_selector('.dropdown-projects', visible: true)
    end

    it 'shows the date filter' do
      expect(page).to have_selector('.js-daterange-picker', visible: true)
    end

    it 'shows the path navigation' do
      expect(page).to have_selector(path_nav_selector)
    end

    it 'shows the filter bar' do
      expect(page).to have_selector(filter_bar_selector, visible: false)
    end
  end

  context 'with path navigation feature flag disabled' do
    before do
      stub_feature_flags(value_stream_analytics_path_navigation: false)

      select_group
    end

    it 'shows the path navigation' do
      expect(page).not_to have_selector(path_nav_selector)
    end
  end

  # Adding this context as part of a fix for https://gitlab.com/gitlab-org/gitlab/-/issues/233439
  # This can be removed when the feature flag is removed
  context 'create multiple value streams disabled' do
    before do
      stub_feature_flags(value_stream_analytics_create_multiple_value_streams: false)

      select_group
    end

    it 'displays the list of stages' do
      expect(page).to have_selector(stage_nav_selector, visible: true)
    end

    it 'displays the duration chart' do
      expect(page).to have_selector(duration_stage_selector, visible: true)
    end
  end

  shared_examples 'group value stream analytics' do
    context 'summary table', :js do
      it 'will display recent activity' do
        page.within(find('.js-recent-activity')) do
          expect(page).to have_content(_('Recent Activity'))
        end
      end

      it 'will display time metrics' do
        page.within(find('.js-recent-activity')) do
          expect(page).to have_content(_('Time'))
        end
      end
    end

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

  context 'with a group selected' do
    card_metric_selector = '.js-recent-activity .js-metric-card-item'

    before do
      select_group

      expect(page).to have_css(card_metric_selector)
    end

    it_behaves_like 'group value stream analytics'

    it 'displays the number of issues' do
      issue_count = page.all(card_metric_selector)[2]

      expect(issue_count).to have_content(n_('New Issue', 'New Issues', 3))
      expect(issue_count).to have_content('3')
    end

    it 'displays the number of deploys' do
      deploys_count = page.all(card_metric_selector)[3]

      expect(deploys_count).to have_content(n_('Deploy', 'Deploys', 0))
      expect(deploys_count).to have_content('-')
    end

    it 'displays the deployment frequency' do
      deployment_frequency = page.all(card_metric_selector).last

      expect(deployment_frequency).to have_content(_('Deployment Frequency'))
      expect(deployment_frequency).to have_content('-')
    end

    it 'displays the lead time' do
      lead_time = page.all(card_metric_selector).first

      expect(lead_time).to have_content(_('Lead Time'))
      expect(lead_time).to have_content('-')
    end

    it 'displays the cycle time' do
      cycle_time = page.all(card_metric_selector)[1]

      expect(cycle_time).to have_content(_('Cycle Time'))
      expect(cycle_time).to have_content('-')
    end
  end

  context 'with a sub group selected' do
    before do
      select_group(sub_group)
    end

    it_behaves_like 'group value stream analytics'
  end

  def select_stage(name)
    string_id = "CycleAnalyticsStage|#{name}"
    page.find('.stage-nav .stage-nav-item .stage-name', text: s_(string_id), match: :prefer_exact).click

    wait_for_requests
  end

  def create_merge_request(id, extra_params = {})
    params = {
      id: id,
      target_branch: 'master',
      source_project: project2,
      source_branch: "feature-branch-#{id}",
      title: "mr name#{id}",
      created_at: 2.days.ago
    }.merge(extra_params)

    create(:merge_request, params)
  end

  context 'with lots of data', :js do
    let_it_be(:issue) { create(:issue, project: project, created_at: 5.days.ago) }

    around do |example|
      Timecop.freeze { example.run }
    end

    before do
      create_cycle(user, project, issue, mr, milestone, pipeline)

      issue.metrics.update!(first_mentioned_in_commit_at: mr.created_at - 5.hours)
      mr.metrics.update!(first_deployed_to_production_at: mr.created_at + 2.hours, merged_at: mr.created_at + 1.hour)

      deploy_master(user, project, environment: 'staging')
      deploy_master(user, project)

      select_group
    end

    dummy_stages = [
      { title: 'Issue', description: 'Time before an issue gets scheduled', events_count: 1, median: '5 days' },
      { title: 'Plan', description: 'Time before an issue starts implementation', events_count: 0, median: 'Not enough data' },
      { title: 'Code', description: 'Time until first merge request', events_count: 1, median: 'about 5 hours' },
      { title: 'Test', description: 'Total test time for all commits/merges', events_count: 0, median: 'Not enough data' },
      { title: 'Review', description: 'Time between merge request creation and merge/close', events_count: 1, median: 'about 1 hour' },
      { title: 'Staging', description: 'From merge request merge until deploy to production', events_count: 1, median: 'about 1 hour' },
      { title: 'Total', description: 'From issue creation until deploy to production', events_count: 1, median: '5 days' }
    ]

    it 'each stage will have median values', :sidekiq_might_not_need_inline do
      stages = page.all('.stage-nav .stage-median').collect(&:text)

      stages.each_with_index do |median, index|
        expect(median).to eq(dummy_stages[index][:median])
      end
    end

    it 'each stage will display the events description when selected', :sidekiq_might_not_need_inline do
      dummy_stages.each do |stage|
        select_stage(stage[:title])

        if stage[:events_count] == 0
          expect(page).not_to have_selector('.stage-events .events-description')
        else
          expect(page.find('.stage-events .events-description').text).to have_text(_(stage[:description]))
        end
      end
    end

    it 'each stage with events will display the stage events list when selected', :sidekiq_might_not_need_inline do
      dummy_stages.each do |stage|
        select_stage(stage[:title])

        if stage[:events_count] == 0
          expect(page).not_to have_selector('.stage-events .stage-event-item')
        else
          expect(page).to have_selector('.stage-events .stage-event-list')
          expect(page.all('.stage-events .stage-event-item').length).to eq(stage[:events_count])
        end
      end
    end

    it 'each stage will be selectable' do
      dummy_stages.each do |stage|
        select_stage(stage[:title])

        expect(page.find('.stage-nav .active .stage-name').text).to eq(stage[:title])
      end
    end
  end

  describe 'Tasks by type chart', :js do
    context 'enabled' do
      before do


        sign_in(user)
      end

      context 'with data available' do
        before do
          3.times do |i|
            create(:labeled_issue, created_at: i.days.ago, project: create(:project, group: group), labels: [group_label1])
            create(:labeled_issue, created_at: i.days.ago, project: create(:project, group: group), labels: [group_label2])
          end


          select_group
        end

        it 'displays the chart' do
          expect(page).to have_text(s_('CycleAnalytics|Type of work'))

          expect(page).to have_text(s_('CycleAnalytics|Tasks by type'))
        end

        it 'has 2 labels selected' do
          expect(page).to have_text('Showing Issues and 2 labels')
        end

        it 'has chart filters' do
          expect(page).to have_css('.js-tasks-by-type-chart-filters')
        end
      end

      context 'no data available' do
        before do
          select_group
        end

        it 'shows the no data available message' do
          expect(page).to have_text(s_('CycleAnalytics|Type of work'))

          expect(page).to have_text(_('There is no data available. Please change your selection.'))
        end
      end
    end
  end

  describe 'Create value stream', :js do
    let(:custom_value_stream_name) { "Test value stream" }
    let(:value_stream_dropdown) { page.find(value_stream_selector) }

    def toggle_value_stream_dropdown
      value_stream_dropdown.click
    end

    before do

      select_group
    end

    it 'can create a value stream' do
      toggle_value_stream_dropdown

      page.find_button(_('Create new Value Stream')).click

      fill_in 'create-value-stream-name', with: custom_value_stream_name
      page.find_button(_('Create Value Stream')).click

      expect(page).to have_text(_("'%{name}' Value Stream created") % { name: custom_value_stream_name })
    end
  end
end
