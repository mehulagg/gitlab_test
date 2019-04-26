module Projects
  module Security
    class DependenciesController < Projects::ApplicationController
      before_action :check_feature_flag!
      before_action :push_feature_flag_to_frontend

      def check_feature_flag!
        render_404 unless Feature.enabled?(:bill_of_materials, default_enabled: false)
      end

      def push_feature_flag_to_frontend
        push_frontend_feature_flag(:bill_of_materials)
      end
    end
  end
end
