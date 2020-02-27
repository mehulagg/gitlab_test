# frozen_string_literal: true

require 'spec_helper'

describe 'Add an issue to an Epic' do
  include GraphqlHelpers

  let_it_be(:current_user) { create(:user) }
  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, namespace: group) }
  let(:epic) { create(:epic, group: group) }
  let(:issue) { create(:issue, project: project) }

  let(:mutation) do
    params = { group_path: group.full_path, iid: epic.iid.to_s, issue_iid: issue.iid.to_s, project_path: project.full_path }

    graphql_mutation(:epic_add_issue, params)
  end

  def mutation_response
    graphql_mutation_response(:epic_add_issue)
  end

  context 'when epics feature is disabled' do
    it_behaves_like 'a mutation that returns top-level errors',
                    errors: ['The resource that you are attempting to access does not exist '\
               'or you don\'t have permission to perform this action']

    it 'does not add issue to the epic' do
      post_graphql_mutation(mutation, current_user: current_user)

      expect(issue.epic).to be_nil
    end
  end

  context 'when epics feature is enabled' do
    before do
      stub_licensed_features(epics: true)
      group.add_developer(current_user)
    end

    it 'adds the issue to the epic' do
      post_graphql_mutation(mutation, current_user: current_user)

      expect(issue.reload.epic).to eq(epic)
      expect(graphql_errors).to be_nil
    end
  end
end
