# frozen_string_literal: true

require 'spec_helper'

describe Projects::Packages::PackagesController, '(JavaScript fixtures)', type: :controller do
  include JavaScriptFixturesHelpers

  let(:admin) { create(:admin) }
  let(:namespace) { create(:namespace, name: 'frontend-fixtures' )}
  let(:project) { create(:project, :repository, namespace: namespace, path: 'packages-project') }
  let(:package) { create(:maven_package, project: project) }

  render_views

  before(:all) do
    clean_frontend_fixtures('package/')
  end

  before do
    stub_licensed_features(packages: true)
    sign_in(admin)
  end

  it 'package/packages.json' do
    get :index, params: {
      namespace_id: project.namespace.to_param,
      project_id: project
    }, format: :json

    Rails.logger.info(response)

    expect(response).to be_successful
  end
end
