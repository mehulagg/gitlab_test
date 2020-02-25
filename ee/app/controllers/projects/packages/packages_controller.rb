# frozen_string_literal: true

module Projects
  module Packages
    class PackagesController < Projects::ApplicationController
      include PackagesAccess

      before_action :authorize_destroy_package!, only: [:destroy]

      def index
      end

      def show
        @package = project.packages.find(params[:id])
        @package_files = @package.package_files.recent
      end

      def destroy
        @package = project.packages.find(params[:id])
        @package.destroy

        redirect_to project_packages_path(@project), status: :found, notice: _('Package was removed')
      end
    end
  end
end
