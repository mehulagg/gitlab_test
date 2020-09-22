# frozen_string_literal: true

module Projects
  class DastScannerProfilesController < Projects::ApplicationController
    before_action :authorize_read_on_demand_scans!

    def new
    end

    def edit
      @scanner_profile = @project
        .dast_scanner_profiles
        .find(params[:id])
    end
  end
end
