# frozen_string_literal: true

class Projects::EvidencesController < Projects::ApplicationController
  before_action :require_non_empty_project
  before_action :release
  before_action :authorize_read_release!
  before_action :authorize_read_release_evidence!

  def show
    byebug
    respond_to do |format|
      format.json do
        render json: evidence.evidence_summary
      end
    end
  end

  private

  def authorize_read_release_evidence!
    access_denied! unless Feature.enabled?(:release_evidence, project, default_enabled: true)
    access_denied! unless can?(current_user, :read_release_evidence, release)
  end

  def release
    byebug
    @release ||= project.releases.find_by_tag!(sanitized_tag_name)
  end

  def evidence
    release.evidence.find(params[:id])
  end

  def sanitized_tag_name
    CGI.unescape(params[:tag])
  end
end
