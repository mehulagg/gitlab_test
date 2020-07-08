# frozen_string_literal: true

module Projects
  module Integrations
    module Jira
      class SearchSuggestionsController < Projects::ApplicationController
        include RecordUserLastActivity

        # before_action :check_feature_enabled!

        # before_action do
        #   push_frontend_feature_flag(:jira_integration, project)
        #   push_frontend_feature_flag(:vue_issuables_list, project)
        # end

        def index
          respond_to do |format|
            format.json do
              render json: search_suggestions
            end
          end
        end

        protected

        def check_feature_enabled!
          return render_404 unless Feature.enabled?(:jira_integration, project)
        end

        private

        def search_suggestions
          @project.jira_service.client.get("/rest/api/2/jql/autocompletedata/suggestions?fieldName=status")["results"]
        end
      end
    end
  end
end
