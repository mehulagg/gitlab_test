# frozen_string_literal: true
require 'spec_helper'

describe DesignManagement::DeleteDesignsService do
  let(:issue) { create(:issue, project: project) }
  let(:project) { create(:project) }
  let(:user) { project.owner }
  let(:design_repository) { EE::Gitlab::GlRepository::DESIGN.repository_accessor.call(project) }
  let(:design_collection) { DesignManagement::DesignCollection.new(issue) }

  subject(:service) { described_class.new(project, user, issue: issue, designs: designs) }

  shared_examples 'a service error' do
    it 'returns an error', :aggregate_failures do
      expect(service.execute).to match(a_hash_including(status: :error))
    end
  end

  shared_examples 'a success' do
    it 'returns successfully', :aggregate_failures do
      expect(service.execute).to match(a_hash_including(status: :success))
    end
  end

  describe "#execute" do
    def create_designs(how_many = 3)
      Array.new(how_many) { create(:design, issue: issue) }
    end

    context "when the feature is not available" do
      before do
        stub_licensed_features(design_management: false)
      end

      let(:designs) { create_designs }

      it_behaves_like "a service error"
    end

    context "when the feature is available" do
      before do
        stub_licensed_features(design_management: true)
      end

      context 'no designs were passed' do
        let(:designs) { [] }

        it_behaves_like "a success"
      end
    end
  end
end
