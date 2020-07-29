# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::IssueTypeCountsResolver do
  include GraphqlHelpers

  describe '#resolve' do
    let_it_be(:current_user) { create(:user) }
    let_it_be(:project) { create(:project) }
    let(:args) { {} }

    subject { resolve_issue_type_counts(args) }

    it { is_expected.to be_a(Gitlab::Issues::IssueTypeCounts) }
    specify { expect(subject.project).to eq(project) }

    private

    def resolve_issue_type_counts(args = {}, context = { current_user: current_user })
      resolve(described_class, obj: project, args: args, ctx: context)
    end
  end
end
