# frozen_string_literal: true

require 'spec_helper'

RSpec.describe "projects/dast_profiles/index", type: :view do
  before do
    @project = create(:project)
    render
  end

  it 'renders Vue app root' do
    expect(rendered).to have_selector('.js-dast-profiles')
  end

  it 'passes new dast site profile path' do
    expect(rendered).to include '/on_demand_scans/profiles/dast_site_profiles/new'
  end

  it 'passes new dast scanner profile path' do
    expect(rendered).to include '/on_demand_scans/profiles/dast_scanner_profiles/new'
  end

  it 'passes project\'s full path' do
    expect(rendered).to include @project.path_with_namespace
  end
end
