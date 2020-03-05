# frozen_string_literal: true

require 'spec_helper'
require Rails.root.join('db', 'migrate', '20200305151736_clean_up_invalid_project_service_data.rb')

describe CleanUpInvalidProjectServiceData, :migration do
  let(:services) { table(:services) }
  let(:project) { table(:projects).create!(namespace_id: 1) }

  before do
    services.create!(template: true, project_id: project.id, type: 'ServiceTemplateAndProjectService')
  end

  it 'sets template to false when it is a service template and attached to a project' do
    migrate!

    service_template_and_project_service = services.where(type: 'ServiceTemplateAndProjectService').first

    expect(service_template_and_project_service.template).to eq(false)
    expect(service_template_and_project_service.project_id).not_to eq(nil)
  end
end
