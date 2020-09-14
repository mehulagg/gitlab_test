# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Admin::PropagateServiceTemplate do
  describe '.propagate' do
    let!(:service_template) do
      PushoverService.create!(
        template: true,
        active: true,
        push_events: false,
        properties: {
          device: 'MyDevice',
          sound: 'mic',
          priority: 4,
          user_key: 'asdf',
          api_key: '123456789'
        }
      )
    end

    let!(:project) { create(:project) }
    let(:excluded_attributes) { %w[id project_id template created_at updated_at default] }

    it 'creates services for projects' do
      expect(project.pushover_service).to be_nil

      described_class.propagate(service_template)

      expect(project.reload.pushover_service).to be_present
    end

    it 'creates services for a project that has another service' do
      BambooService.create!(
        active: true,
        project: project,
        properties: {
          bamboo_url: 'http://gitlab.com',
          username: 'mic',
          password: 'password',
          build_key: 'build'
        }
      )

      expect(project.pushover_service).to be_nil

      described_class.propagate(service_template)

      expect(project.reload.pushover_service).to be_present
    end

    it 'does not create the service if it exists already' do
      other_service = BambooService.create!(
        template: true,
        active: true,
        properties: {
          bamboo_url: 'http://gitlab.com',
          username: 'mic',
          password: 'password',
          build_key: 'build'
        }
      )

      Service.build_from_integration(project.id, service_template).save!
      Service.build_from_integration(project.id, other_service).save!

      expect { described_class.propagate(service_template) }
        .not_to change { Service.count }
    end

    it 'creates the service containing the template attributes' do
      described_class.propagate(service_template)

      expect(project.pushover_service.properties).to eq(service_template.properties)

      expect(project.pushover_service.attributes.except(*excluded_attributes))
        .to eq(service_template.attributes.except(*excluded_attributes))
    end

    context 'service with data fields' do
      include JiraServiceHelper

      let(:service_template) do
        stub_jira_service_test

        JiraService.create!(
          template: true,
          active: true,
          push_events: false,
          url: 'http://jira.instance.com',
          username: 'user',
          password: 'secret'
        )
      end

      it 'creates the service containing the template attributes' do
        described_class.propagate(service_template)

        expect(project.jira_service.attributes.except(*excluded_attributes))
          .to eq(service_template.attributes.except(*excluded_attributes))

        excluded_attributes = %w[id service_id created_at updated_at]
        expect(project.jira_service.data_fields.attributes.except(*excluded_attributes))
          .to eq(service_template.data_fields.attributes.except(*excluded_attributes))
      end
    end

    describe 'bulk update', :use_sql_query_cache do
      let(:project_total) { 5 }

      before do
        stub_const('Admin::PropagateServiceTemplate::BATCH_SIZE', 3)

        project_total.times { create(:project) }

        described_class.propagate(service_template)
      end

      it 'creates services for all projects' do
        expect(Service.all.reload.count).to eq(project_total + 2)
      end
    end

    describe 'external tracker' do
      it 'updates the project external tracker' do
        service_template.update!(category: 'issue_tracker')

        expect { described_class.propagate(service_template) }
          .to change { project.reload.has_external_issue_tracker }.to(true)
      end
    end

    describe 'external wiki' do
      it 'updates the project external tracker' do
        service_template.update!(type: 'ExternalWikiService')

        expect { described_class.propagate(service_template) }
          .to change { project.reload.has_external_wiki }.to(true)
      end
    end
  end
end
