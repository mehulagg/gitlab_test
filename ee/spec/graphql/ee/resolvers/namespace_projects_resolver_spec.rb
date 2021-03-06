# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::NamespaceProjectsResolver do
  include GraphqlHelpers

  let(:current_user) { create(:user) }

  context "with a group" do
    let(:group) { create(:group) }
    let(:project_1) { create(:project, namespace: group) }
    let(:project_2) { create(:project, namespace: group) }

    before do
      project_1.add_developer(current_user)
      project_2.add_developer(current_user)
      create(:vulnerability, project: project_1)
    end

    describe '#resolve' do
      subject(:projects) { resolve_projects(has_vulnerabilities) }

      context 'when the `has_vulnerabilities` parameter is not truthy' do
        let(:has_vulnerabilities) { false }

        it { is_expected.to contain_exactly(project_1, project_2) }
      end

      context 'when the `has_vulnerabilities` parameter is truthy' do
        let(:has_vulnerabilities) { true }

        it { is_expected.to contain_exactly(project_1) }
      end
    end
  end

  def resolve_projects(has_vulnerabilities)
    args = {
      include_subgroups: false,
      has_vulnerabilities: has_vulnerabilities,
      sort: :similarity,
      search: nil
    }

    resolve(described_class, obj: group, args: args, ctx: { current_user: current_user })
  end
end
