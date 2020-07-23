# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::GroupCoverageReport do
  subject(:group_coverage_report) { described_class.new(group: group, user: user) }

  let_it_be(:user)     { create(:user) }
  let_it_be(:group)    { create(:group) }
  let_it_be(:subgroup) { create(:group, parent: group) }

  let_it_be(:project_a) { create(:project, namespace: group) }
  let_it_be(:project_b) { create(:project, namespace: group) }
  let_it_be(:project_z) { create(:project, namespace: subgroup) }

  let_it_be(:daily_coverage_data) do
    create_daily_coverage(project_a, 'rspec', 80.0, '2020-07-08')
    create_daily_coverage(project_a, 'karma', 30.0, '2020-07-08')
    create_daily_coverage(project_b, 'rspec', 40.0, '2020-07-08')

    create_daily_coverage(project_a, 'rspec', 90.0, '2020-07-09')
    create_daily_coverage(project_a, 'karma', 70.0, '2020-07-09')
    create_daily_coverage(project_b, 'rspec', 50.0, '2020-07-09')
    create_daily_coverage(project_b, 'karma', 30.0, '2020-07-09')

    create_daily_coverage(project_z, 'rspec', 55.0, '2020-07-09')
  end

  before do
    group.add_owner(user)
  end

  describe '#daily_summary' do
    subject { group_coverage_report.daily_summary }

    it 'returns a daily summary with correct averages' do
      expect(subject).to eq([
        {
          date: '2020-07-09', average_coverage: 60.0, projects_count: 2, builds_count: 4, projects: [
            {
              project_name: project_a.name, builds: [
                { build_name: 'karma', coverage: 70.0 },
                { build_name: 'rspec', coverage: 90.0 }
              ]
            },
            {
              project_name: project_b.name, builds: [
                { build_name: 'karma', coverage: 30.0 },
                { build_name: 'rspec', coverage: 50.0 }
              ]
            }
          ]
        },
        {
          date: '2020-07-08', average_coverage: 50.0, projects_count: 2, builds_count: 3, projects: [
            {
              project_name: project_a.name, builds: [
                { build_name: 'karma', coverage: 30.0 },
                { build_name: 'rspec', coverage: 80.0 }
              ]
            },
            {
              project_name: project_b.name, builds: [
                { build_name: 'rspec', coverage: 40.0 }
              ]
            }
          ]
        }
      ])
    end
  end

  describe '#report_results' do
    subject { group_coverage_report.send(:report_results) }

    it 'does not include builds from subgroup projects' do
      expect(subject.map(&:project).uniq).to contain_exactly(project_a, project_b)
    end
  end

  def create_daily_coverage(project, group_name, coverage, date)
    create(:ci_daily_build_group_report_result,
      project: project,
      ref_path: 'refs/heads/master',
      group_name: group_name,
      data: { 'coverage' => coverage },
      date: date
    )
  end
end
