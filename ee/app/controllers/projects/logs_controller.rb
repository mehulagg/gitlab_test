# frozen_string_literal: true

module Projects
  class LogsController < Projects::ApplicationController
    before_action :authorize_read_pod_logs!
    before_action :environment

    def index
      if environment.nil?
        render :empty_logs
      else
        render :index
      end
    end

    private

    def index_params
      params.permit(:environment_name)
    end

    def environment
      @environment ||= if index_params.key?(:environment_name)
                         EnvironmentsFinder.new(project, current_user, name: index_params[:environment_name]).find.first
                       else
                         project.default_environment
                       end
    end
  end
end
