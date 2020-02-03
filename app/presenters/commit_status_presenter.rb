# frozen_string_literal: true
class CommitStatusPresenter < Gitlab::View::Presenter::Delegated
  CALLOUT_FAILURE_MESSAGES = {
    unknown_failure: 'There is an unknown failure, please try again',
    script_failure: nil,
    api_failure: 'There has been an API failure, please try again',
    stuck_or_timeout_failure: 'There has been a timeout failure or the job got stuck. Check your timeout limits or try again',
    runner_system_failure: 'There has been a runner system failure, please try again',
    missing_dependency_failure: 'There has been a missing dependency failure',
    runner_unsupported: 'Your runner is outdated, please upgrade your runner',
    stale_schedule: 'Delayed job could not be executed by some reason, please try again',
    job_execution_timeout: 'The script exceeded the maximum execution time set for the job',
    archived_failure: 'The job is archived and cannot be run',
    unmet_prerequisites: 'The job failed to complete prerequisite tasks',
    scheduler_failure: 'The scheduler failed to assign job to the runner, please try again or contact system administrator',
    data_integrity_failure: 'There has been a structural integrity problem detected, please contact system administrator',
    vault_timeout_failure: 'There has been a timeout failure while fetching the Vault secrets. Reduce the number of secrets or try again',
    vault_missing_secret_failure: 'One or more Vault secrets are missing. Please check your definitions and permissions',
    vault_generic_failure: 'There has been a failure while fetching the Vault secrets. Please check your configuration and permissions'
  }.freeze

  private_constant :CALLOUT_FAILURE_MESSAGES

  presents :build

  prepend_if_ee('::EE::CommitStatusPresenter') # rubocop: disable Cop/InjectEnterpriseEditionModule

  def self.callout_failure_messages
    CALLOUT_FAILURE_MESSAGES
  end

  def callout_failure_message
    self.class.callout_failure_messages.fetch(failure_reason.to_sym)
  end

  def recoverable?
    failed? && !unrecoverable?
  end

  def unrecoverable?
    script_failure? || missing_dependency_failure? || archived_failure? || scheduler_failure? || data_integrity_failure?
  end
end
