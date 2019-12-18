# frozen_string_literal: true

class Projects::ResultsController < Projects::ApplicationController

  layout 'project'

  def index
    # return head :no_content unless Feature.enabled?(:job_results, @project)

    @results = build.results.all

    respond_to do |format|
      format.html
      format.json { render json: @results }
    end
  end

  def new
    @result = Result.new(job_id: build.id)
  end

  def create

  end

  private

  def build
    @build ||= @project.builds.find(params[:id])
                 .present(current_user: current_user)
  end

  def results_params
    params.require(:name).require(:job_id).permit(:result,
                                                  :field1, :field2,
                                                  :field3, :field4,
                                                  :field5, :field6,
                                                  :field7, :field8,
                                                  :field9, :field10)
  end
end

Projects::ResultsController.prepend_if_ee('EE::Projects::ResultsController')
