# frozen_string_literal: true

require 'spec_helper'

describe DeleteBranchService do
  let(:project) { create(:project, :repository) }
  let(:repository) { project.repository }
  let(:user) { create(:user) }
  let(:service) { described_class.new(project, user) }

  describe '#execute' do
    context 'when there is a push rule matching the branch name' do
      before do
        project.add_developer(user)
        create(:push_rule, branch_name_regex: '^(w*)$')
      end

      it 'removes the branch' do
        expect(branch_exists?('add-pdf-file')).to be true

        result = service.execute('add-pdf-file')

        expect(result[:status]).to eq :success
        expect(branch_exists?('add-pdf-file')).to be false
      end
    end
  end

  def branch_exists?(branch_name)
    repository.ref_exists?("refs/heads/#{branch_name}")
  end
end
