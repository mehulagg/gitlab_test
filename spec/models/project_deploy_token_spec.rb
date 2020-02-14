# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ProjectDeployToken, type: :model do
  let(:project) { create(:project) }
  let(:deploy_token) { create(:deploy_token) }

  subject(:project_deploy_token) { create(:project_deploy_token, project: project, deploy_token: deploy_token) }

  it { is_expected.to belong_to :project }
  it { is_expected.to belong_to :deploy_token }

  it { is_expected.to validate_presence_of :deploy_token }
  it { is_expected.to validate_presence_of :project }
  it { is_expected.to validate_uniqueness_of(:deploy_token_id).scoped_to(:project_id) }

  describe '#find_by_deploy_token' do
    it 'finds a deploy token by deploy_token_id' do
      expect(described_class.all.find_by_deploy_token(project_deploy_token.id))
        .to eq project_deploy_token
    end
  end
end
