# frozen_string_literal: true

require 'spec_helper'

require Rails.root.join('db', 'migrate', '20200219165820_add_services_project_id_template_unique_constraint.rb')

describe AddServicesProjectIdTemplateUniqueConstraint, :migration do
  let(:services) { table(:services) }
  let(:project) { table(:projects).create!(namespace_id: 1) }

  before do
    services.create!(project_id: project.id, template: true)
    services.create!(template: true)
  end

  it 'sets template = false for services with a project_id' do
    migrate!

    expect(services.where(template: true).count).to eq(1)
    expect(services.where.not(project_id: nil).count).to eq(1)
  end

  it 'adds a constraint that does not allow a service to be a template and a project service' do
    migrate!

    expect { services.create!(project_id: project.id, template: true) }.to raise_error(ActiveRecord::StatementInvalid)
  end
end
