# frozen_string_literal: true

module EE
  module Projects
    module AutocompleteSourcesController
      extend ActiveSupport::Concern

      prepended do
        before_action :authorize_read_vulnerability!, only: :vulnerabilities
      end

      def epics
        return render_404 unless project.group.feature_available?(:epics)

        render json: autocomplete_service.epics
      end

      def vulnerabilities
        render json: autocomplete_service.vulnerabilities
      end
    end
  end
end
