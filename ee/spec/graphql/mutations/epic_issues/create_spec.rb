# frozen_string_literal: true
require 'spec_helper'

describe Mutations::EpicIssues::Create do
  let(:group)   { create(:group) }
  let(:project) { create(:project, namespace: group) }
  let(:epic)    { create(:epic, group: group) }
  let(:issue)   { create(:issue, project: project) }
  let(:user)    { issue.author }

  subject(:mutation) { described_class.new(object: nil, context: { current_user: user }) }

  describe '#resolve' do
    subject { mutation.resolve(project_path: project.full_path, iid: issue.iid, epic_iid: epic.iid) }

    it 'raises an error if the resource is not accessible to the user' do
      expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
    end

    context 'when the user can update the issue' do
      before do
        project.add_developer(user)
        stub_licensed_features(epics: true)
      end

      context 'when the user can not update the epic' do
        it 'does not assign the epic to the issue' do
          expect(subject[:id]).to be_nil
          expect(subject[:issue]&.epic).to be_nil
          expect(subject[:errors]).to eq("No Issue found for given params")
        end
      end

      context 'when the user can update the epic' do
        before do
          group.add_developer(user)
        end

        it 'returns the issue with correct epic assigned' do
          subject

          epic_issue_link_id = EpicIssue.find_by(issue: issue, epic: epic).try(:id)

          expect(subject[:id]).to eq(epic_issue_link_id)
          expect(subject[:epic]).to eq(epic)
          expect(subject[:issue]).to eq(issue)
          expect(subject[:issue]&.epic).to eq(epic)
          expect(subject[:errors]).to be_empty
        end
      end
    end
  end
end
