# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::Boards::Issues::IssueMoveList do
  let_it_be(:group) { create(:group, :public) }
  let_it_be(:epic) { create(:epic, group: group) }
  let_it_be(:project) { create(:project, group: group) }
  let_it_be(:board) { create(:board, group: group) }
  let_it_be(:user)  { create(:user) }
  let_it_be(:development) { create(:label, project: project, name: 'Development') }
  let_it_be(:testing) { create(:label, project: project, name: 'Testing') }
  let_it_be(:list1)   { create(:list, board: board, label: development, position: 0) }
  let_it_be(:list2)   { create(:list, board: board, label: testing, position: 1) }
  let_it_be(:issue1) { create(:labeled_issue, project: project, labels: [development]) }
  let_it_be(:existing_issue1) { create(:labeled_issue, project: project, labels: [testing], relative_position: 10) }
  let_it_be(:existing_issue2) { create(:labeled_issue, project: project, labels: [testing], relative_position: 50) }

  let(:current_user) { user }
  let(:mutation) { described_class.new(object: nil, context: { current_user: current_user }, field: nil) }
  let(:params) { { board: board, project_path: project.full_path, iid: issue1.iid, epic: epic } }
  let(:move_params) do
    {
      from_list_id: list1.id,
      to_list_id: list2.id,
      move_before_id: existing_issue2.id,
      move_after_id: existing_issue1.id
    }
  end

  before_all do
    group.add_developer(user)
  end

  subject do
    mutation.resolve(params.merge(move_params))
  end

  describe '#resolve' do
    context 'when epics feature is enabled' do
      before do
        stub_licensed_features(epics: true)
      end

      context 'when user have access to resources' do
        it 'moves and repositions issue' do
          subject

          expect(issue1.reload.labels).to eq([testing])
          expect(issue1.epic).to eq(epic)
          expect(issue1.relative_position).to be < existing_issue2.relative_position
          expect(issue1.relative_position).to be > existing_issue1.relative_position
        end
      end
    end
  end
end
