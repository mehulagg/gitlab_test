# frozen_string_literal: true

module Groups
  class PackagesController < Groups::ApplicationController

    before_action :verify_packages_enabled!

    def index
    end

    private

    def verify_packages_enabled!
      render_404 unless group.packages_feature_available?
    end
  end
end
