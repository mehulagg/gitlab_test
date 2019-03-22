# frozen_string_literal: true

module Groups
  class DependencyProxiesController < Groups::ApplicationController
    before_action :authorize_admin_group!, only: :update
    before_action :dependency_proxy

    def show
      @blobs_count = group.dependency_proxy_blobs.count
      @blobs_total_size = group.dependency_proxy_blobs.size_sum
    end

    def update
      dependency_proxy.update(dependency_proxy_params)

      redirect_to group_dependency_proxy_path(group)
    end

    private

    def dependency_proxy
      @dependency_proxy ||=
        group.dependency_proxy_setting || group.create_dependency_proxy_setting
    end

    def dependency_proxy_params
      params.require(:dependency_proxy_group_setting).permit(:enabled)
    end
  end
end
