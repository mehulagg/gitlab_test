# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Issues::IssueTypeCounts do
  let_it_be(:current_user) { create(:user) }
  let_it_be(:project) { create(:project) }
  let_it_be(:issue) { create(:issue, project: project) }
  let_it_be(:incident) { create(:incident, project: project) }
  let_it_be(:issue_other_proj) { create(:alert_management_alert) }
  let(:params) { {} }

  describe '#execute' do
    subject(:counts) { described_class.new(current_user, project, params) }

    context 'for an unauthorized user' do
      it 'returns zero for all issue types' do
        expect(counts.all).to eq(0)

        Issue.issue_types.each_key do |status|
          expect(counts.send(status)).to eq(0)
        end
      end
    end

    context 'for an authorized user' do
      before do
        project.add_developer(current_user)
      end

      it 'returns the correct counts for each status' do
        expect(counts.all).to eq(2)
        expect(counts.incident).to eq(1)
        expect(counts.issue).to eq(1)
      end

      context 'when filtering params are included' do
        let(:params) { { issue_types: Issue.issue_types.keys.first } }

        it 'returns the correct counts for each status' do
          expect(counts.all).to eq(1)
          expect(counts.issue).to eq(1)
          expect(counts.incident).to eq(0)
        end
      end
    end
  end
end
