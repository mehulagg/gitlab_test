# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::OnDemandScansHelper do
  describe '#on_demand_scans_data' do
    let(:project) { create(:project) }

    it 'returns proper data' do
      expect(helper.on_demand_scans_data(project)).to match(
        'help-page-path' => help_page_path('user/application_security/dast/index', anchor: 'on-demand-scans'),
        'empty-state-svg-path' => match_asset_path('/assets/illustrations/empty-state/ondemand-scan-empty.svg'),
        'default-branch' => project.default_branch,
        'project-path' => project.path_with_namespace,
        'scanner-profiles-library-path' => project_profiles_path(project, anchor: 'scanner-profiles'),
        'site-profiles-library-path' => project_profiles_path(project, anchor: 'site-profiles'),
        'new-scanner-profile-path' => new_project_dast_scanner_profile_path(project),
        'new-site-profile-path' => new_project_dast_site_profile_path(project)
      )
    end
  end
end
