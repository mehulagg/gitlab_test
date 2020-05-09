# frozen_string_literal: true

require 'spec_helper'

describe EmailsOnPushIntegration do
  describe 'inheritance' do
    let!(:instance_level_service) { create(:emails_on_push_service, :instance, integration_properties: instance_level_properties) }
    let(:instance_level_properties) { { recipients: 'admin@example.com' } }
    let!(:project_level_service) { create(:emails_on_push_service, project: project, integration_properties: project_level_properties) }
    let(:project) { create(:project, group: group) }
    let(:group) { create(:group) }
    let(:project_level_properties) { {} }

    it 'inherits recipients from instance level' do
      integration = described_class.find_by_id(project_level_service.id)

      expect(integration.recipients).to eq('admin@example.com')
    end

    context 'with group_level recipients' do
      let!(:group_level_service) { create(:emails_on_push_service, group: group, integration_properties: group_level_properties) }
      let(:group_level_properties) { { recipients: 'group@example.com' } }

      it 'overrides recipients on group level' do
        integration = described_class.find_by_id(project_level_service.id)

        expect(integration.recipients).to eq('group@example.com')
      end

      context 'with project_level recipients' do
        let(:project_level_properties) { { recipients: 'project@example.com' } }

        it 'overrides recipients on project level' do
          integration = described_class.find_by_id(project_level_service.id)

          expect(integration.recipients).to eq('project@example.com')
        end
      end
    end
  end
end
