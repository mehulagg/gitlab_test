# frozen_string_literal: true

module Vulnerabilities
  class RevertToDetectedService < BaseService
    include Gitlab::Allowable

    FindingsRevertResult = Struct.new(:ok?, :finding, :message)
    REVERT_PARAMS = { resolved_by: nil, resolved_at: nil, dismissed_by: nil, dismissed_at: nil, confirmed_by: nil, confirmed_at: nil }.freeze

    def initialize(current_user, vulnerability)
      super(current_user, vulnerability)
    end

    def execute
      raise Gitlab::Access::AccessDeniedError unless authorized?

      @vulnerability.transaction do
        result = revert_findings_to_detected_state

        unless result.ok?
          handle_finding_revert_error(result.finding, result.message)
          raise ActiveRecord::Rollback
        end

        update_with_note(@vulnerability, state: Vulnerability.states[:detected], **REVERT_PARAMS)
      end

      @vulnerability
    end

    private

    def destroy_feedback_service_for(finding)
      VulnerabilityFeedback::DestroyService.new(@project, @user, finding.dismissal_feedback)
    end

    def revert_findings_to_detected_state
      @vulnerability
        .findings
        .select { |finding| finding.dismissal_feedback.present? }
        .each do |finding|
          result = destroy_feedback_service_for(finding).execute

          return FindingsRevertResult.new(false, finding, result[:message]) if result[:status] == :error
        end

      FindingsRevertResult.new(true)
    end

    def handle_finding_revert_error(finding, message)
      @vulnerability.errors.add(
        :base,
        :finding_revert_to_detected_error,
        message: _("failed to revert associated finding(id=%{finding_id}) to detected: %{message}") %
          {
            finding_id: finding.id,
            message: message
          })
    end
  end
end
