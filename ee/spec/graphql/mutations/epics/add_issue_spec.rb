# frozen_string_literal: true

require 'spec_helper'

describe Mutations::Epics::AddIssue do
  let(:group) { create(:group) }
  let(:project) { create(:project, namespace: group) }
  let(:issue) { create(:issue, project: project) }
  let(:epic) { create(:epic, group: group) }
  let(:user) { issue.author }

  subject(:mutation) { described_class.new(object: nil, context: { current_user: user }) }

  describe '#resolve' do
    let(:mutated_issue) { subject[:issue] }
    let(:mutated_epic)  { subject[:epic] }

    subject do
      mutation.resolve(
        group_path: group.full_path,
        iid: epic.iid,
        issue_iid: issue.iid,
        project_path: project.full_path
      )
    end

    it 'raises an error if the resource is not accessible to the user' do
      expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
    end

    context 'when the user can update the epic' do
      before do
        stub_licensed_features(epics: true)
        group.add_developer(user)
      end

      it 'adds the issue to the epic' do
        expect(mutated_issue).to eq(issue)
        expect(mutated_epic).to eq(epic)
        expect(mutated_issue.epic).to eq(epic)
        expect(subject[:errors]).to be_empty
      end
    end
  end
end
