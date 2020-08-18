# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::Clusters::Agents::Create do
  subject(:mutation) { described_class.new(object: nil, context: context, field: nil) }

  let(:project_name) { 'agent-graphql-test' }
  let(:project) { create(:project, :custom_repo, files: ["agents/#{project_name}/config.yaml"]) }
  let(:user) { create(:user) }
  let(:context) do
    GraphQL::Query::Context.new(
      query: OpenStruct.new(schema: nil),
      values: { current_user: user },
      object: nil
    )
  end

  specify { expect(described_class).to require_graphql_authorizations(:create_cluster) }

  describe '#resolve' do
    subject { mutation.resolve(project_path: project.full_path, name: project_name) }

    context 'without project permissions' do
      it 'raises an error if the resource is not accessible to the user' do
        expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
      end
    end

    context 'without premium plan' do
      before do
        allow(License).to receive(:current).and_return(create(:license, plan: ::License::STARTER_PLAN))
        project.add_maintainer(user)
      end

      it { expect(subject[:clusters_agent]).to be_nil }
      it { expect(subject[:errors]).to eq(['This feature is only available for premium plans']) }
    end

    context 'with premium plan and user permissions' do
      before do
        allow(License).to receive(:current).and_return(create(:license, plan: ::License::PREMIUM_PLAN))
        project.add_maintainer(user)
      end

      it 'creates a new clusters_agent', :aggregate_failures do
        expect { subject }.to change { ::Clusters::Agent.count }.by(1)
        expect(subject[:cluster_agent].name).to eq(project_name)
        expect(subject[:errors]).to eq([])
      end

      context 'invalid params' do
        subject { mutation.resolve(project_path: project.full_path, name: 'missing-file') }

        it 'generates an error message when config file is missing', :aggregate_failures do
          expect(subject[:clusters_agent]).to be_nil
          expect(subject[:errors]).to eq(["The file 'agents/missing-file/config.yaml' is missing from this repository"])
        end
      end
    end
  end
end
