require 'rails_helper'

describe MergeRequests::ApprovalService, services: true do
  describe '#execute' do
    let(:user)          { build_stubbed(:user) }
    let(:merge_request) { build_stubbed(:merge_request) }
    let(:project)       { merge_request.project }
    let!(:todo)         { create(:todo, user: user, project: project, target: merge_request) }

    subject(:service) { described_class.new(project, user) }

    context 'with invalid approval' do
      before do
        allow(merge_request.approvals).to receive(:new).and_return(double(save: false))
      end

      it 'does not create an approval note' do
        expect(SystemNoteService).not_to receive(:approve_mr)

        service.execute(merge_request)
      end

      it 'does not mark pending todos as done' do
        service.execute(merge_request)

        expect(todo.reload).to be_pending
      end
    end

    context 'with valid approval' do
      it 'creates an approval note' do
        expect(SystemNoteService).to receive(:approve_mr).with(merge_request, user)

        service.execute(merge_request)
      end

      it 'marks pending todos as done' do
        service.execute(merge_request)

        expect(todo.reload).to be_done
      end

      context 'with remaining approvals' do
        it 'does not fire a webhook' do
          expect(merge_request).to receive(:approvals_left).and_return(5)
          expect(service).not_to receive(:execute_hooks)

          service.execute(merge_request)
        end
      end

      context 'with required approvals' do
        it 'fires a webhook' do
          expect(merge_request).to receive(:approvals_left).and_return(0)
          expect(service).to receive(:execute_hooks).with(merge_request, 'approved')

          service.execute(merge_request)
        end
      end
    end
  end
end
