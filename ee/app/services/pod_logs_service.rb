# frozen_string_literal: true

class PodLogsService < ::BaseService
  include Stepable

  attr_reader :environment

  K8S_NAME_MAX_LENGTH = 253

  PARAMS = %w(pod_name container_name).freeze

  SUCCESS_RETURN_KEYS = [:status, :logs].freeze

  steps :check_param_lengths,
    :check_deployment_platform,
    :pod_logs,
    :filter_return_keys

  def initialize(environment, params: {})
    @environment = environment
    @params = filter_params(params.dup).to_hash
  end

  def execute
    execute_steps
  end

  private

  def check_param_lengths(_result)
    pod_name = params['pod_name'].presence
    container_name = params['container_name'].presence

    if pod_name&.length.to_i > K8S_NAME_MAX_LENGTH
      return error(_('pod_name cannot be larger than %{max_length}'\
        ' chars' % { max_length: K8S_NAME_MAX_LENGTH }))
    elsif container_name&.length.to_i > K8S_NAME_MAX_LENGTH
      return error(_('container_name cannot be larger than'\
        ' %{max_length} chars' % { max_length: K8S_NAME_MAX_LENGTH }))
    end

    success(pod_name: pod_name, container_name: container_name)
  end

  def check_deployment_platform(result)
    unless environment.deployment_platform
      return error(_('No deployment platform available'))
    end

    success(result)
  end

  def pod_logs(result)
    response = environment.deployment_platform.read_pod_logs(
      environment.id,
      params[:pod_name],
      namespace,
      container: params[:container_name]
    )

    return { status: :processing } unless response

    if response[:status] == :error
      error(response[:error]).reverse_merge(result)
    else
      success(logs: response[:logs])
    end
  end

  def filter_return_keys(result)
    result.slice(*SUCCESS_RETURN_KEYS)
  end

  def filter_params(params)
    params.slice(*PARAMS)
  end

  def namespace
    environment.deployment_namespace
  end
end
