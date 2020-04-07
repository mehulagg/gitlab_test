# frozen_string_literal: true

module Projects
  module Settings
    class AccessTokenController < Projects::ApplicationController
      def index

      end

      def create
        access_token = Users::CreateAccessTokenService.new(@project, current_user, params)

        if access_token
          @token = access_token.token

          format.html do
            redirect_to project_settings_access_token_controller_path, notice: _("Your new personal access token has been created.")
          end
        end
      end
    end
  end
end
