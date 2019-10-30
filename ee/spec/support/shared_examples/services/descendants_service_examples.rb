# frozen_string_literal: true

require 'spec_helper'

shared_examples 'descendants total' do |method, expected_result|
  let_it_be(:group) { create(:group, :public)}
  let_it_be(:subgroup) { create(:group, :private, parent: group)}
  let_it_be(:user) { create(:user) }
  let_it_be(:parent_epic) { create(:epic, group: group) }
  let_it_be(:epic1) { create(:epic, group: subgroup, parent: parent_epic, state: :opened) }
  let_it_be(:epic2) { create(:epic, group: subgroup, parent: parent_epic, state: :closed) }

  let_it_be(:project) { create(:project, :private, group: group)}
  let_it_be(:issue1) { create(:issue, project: project, state: :opened, weight: 3) }
  let_it_be(:issue2) { create(:issue, project: project, state: :closed, weight: 5) }
  let_it_be(:issue3) { create(:issue, project: project, state: :opened, weight: 7) }
  let_it_be(:issue4) { create(:issue, project: project, state: :closed, weight: 9) }
  let_it_be(:epic_issue1) { create(:epic_issue, epic: parent_epic, issue: issue1) }
  let_it_be(:epic_issue2) { create(:epic_issue, epic: parent_epic, issue: issue2) }
  let_it_be(:epic_issue3) { create(:epic_issue, epic: epic1, issue: issue3) }
  let_it_be(:epic_issue4) { create(:epic_issue, epic: epic2, issue: issue4) }

  subject { described_class.new(parent_epic, user) }

  before do
    stub_licensed_features(epics: true)
  end

  it 'counts inaccessible epics' do
    expect(subject.public_send(method)).to eq 1
  end

  context 'when authorized' do
    before do
      subgroup.add_developer(user)
      project.add_developer(user)
    end

    it "returns correct #{method}" do
      expect(subject.public_send(method)).to eq expected_result
    end
  end
end
