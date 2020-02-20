# frozen_string_literal: true

require 'spec_helper'

describe 'Creating an EpicIssue relation' do
  include GraphqlHelpers

  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, namespace: group) }
  let_it_be(:issue) { create(:issue, project: project) }
  let_it_be(:epic) { create(:epic, group: group) }
  let_it_be(:current_user) { issue.author }

  let(:attributes) do
    {
      iid: issue.iid.to_s,
      epic_iid: epic.iid.to_s
    }
  end

  let(:mutation) do
    params = { project_path: project.full_path }.merge(attributes)

    graphql_mutation(:create_epic_issue, params)
  end

  def mutation_response
    graphql_mutation_response(:create_epic_issue)
  end

  context 'when the user does not have permission' do
    before do
      stub_licensed_features(epics: true)
    end

    it_behaves_like 'a mutation that returns top-level errors',
      errors: ['The resource that you are attempting to access does not exist '\
               'or you don\'t have permission to perform this action']

    it 'does not create epic issue relation' do
      expect { post_graphql_mutation(mutation, current_user: current_user) }.not_to change(epic.issues, :count)
    end
  end

  context 'when the user has permission' do
    before do
      group.add_reporter(current_user)
    end

    context 'when epics are disabled' do
      before do
        stub_licensed_features(epics: false)
      end

      it_behaves_like 'a mutation that returns top-level errors',
        errors: ['The epic that you are attempting to access does not '\
                'exist or you don\'t have permission to perform this action']
    end

    context 'when epics are enabled' do
      before do
        stub_licensed_features(epics: true)
      end

      it 'creates the epic issue relation' do
        expect { post_graphql_mutation(mutation, current_user: current_user) }.to change(epic.issues, :count).by(1)

        issue_hash = mutation_response['issue']
        epic_hash = mutation_response['epic']
        epic_issue_link_id = EpicIssue.find_by(issue: issue, epic: epic).try(:id)

        expect(issue_hash['iid']).to eq(issue.iid.to_s)
        expect(issue_hash['epic']['iid']).to eq(epic.iid.to_s)
        expect(epic_hash['iid']).to eq(epic.iid.to_s)
        expect(mutation_response['id']).to eq(epic_issue_link_id.try(:to_s))
      end

      context 'when the issue iid is not present' do
        let(:attributes) do
          {
            iid: nil,
            epic_iid: epic.iid.to_s
          }
        end

        it_behaves_like 'a mutation that returns top-level errors',
          errors: ['Variable createEpicIssueInput of type CreateEpicIssueInput! '\
                  'was provided invalid value for iid (Expected value to not be null)']

        it 'does not create a epic issue relation' do
          expect { post_graphql_mutation(mutation, current_user: current_user) }.not_to change(epic.issues, :count)
        end
      end

      context 'when the epic iid is not present' do
        let(:attributes) do
          {
            iid: issue.iid.to_s,
            epic_iid: nil
          }
        end

        it_behaves_like 'a mutation that returns top-level errors',
          errors: ['Variable createEpicIssueInput of type CreateEpicIssueInput! '\
                  'was provided invalid value for epicIid (Expected value to not be null)']

        it 'does not create a epic issue relation' do
          expect { post_graphql_mutation(mutation, current_user: current_user) }.not_to change(epic.issues, :count)
        end
      end
    end
  end
end
