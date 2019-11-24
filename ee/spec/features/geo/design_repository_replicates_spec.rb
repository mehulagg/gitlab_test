# frozen_string_literal: true

require 'spec_helper'

describe 'Design repository replicates', :geo do
  include DesignManagementTestHelpers

  let(:project) { create(:project) }
  let(:user) { project.owner }
  let(:issue) { create(:issue, project: project) }
  let(:repository) { project.design_repository }

  context 'when the feature is available' do
    before do
      enable_design_management
    end

    let(:registry_class) { ::Geo::DesignRegistry }

    it_behaves_like 'repository replication feature' do
      def create_repository
        repository.create_if_not_exists

        repository
      end

      def update_repository
        design_files = [fixture_file_upload("spec/fixtures/rails_sample.jpg")]
        design_files.each(&:rewind)

        service = DesignManagement::SaveDesignsService.new(
          project,
          user,
          issue: issue,
          files: design_files
        )
        service.execute
      end
    end
  end
end
