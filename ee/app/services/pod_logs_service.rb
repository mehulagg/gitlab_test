# frozen_string_literal: true

class PodLogsService < ::BaseService
  include Stepable

  attr_reader :cluster

  K8S_NAME_MAX_LENGTH = 253

  PARAMS = %w(namespace pod_name container_name).freeze

  SUCCESS_RETURN_KEYS = [:status, :logs].freeze

  steps :check_param_lengths,
    :pod_logs,
    :filter_return_keys

  def initialize(cluster, params: {})
    @cluster = cluster
    @params = filter_params(params.dup).to_hash
  end

  def execute
    execute_steps
  end

  private

  def check_param_lengths(_result)
    namespace = params['namespace'].presence
    pod_name = params['pod_name'].presence
    container_name = params['container_name'].presence

    if namespace&.length.to_i > K8S_NAME_MAX_LENGTH
      return error(_('namespace cannot be larger than %{max_length}'\
        ' chars' % { max_length: K8S_NAME_MAX_LENGTH }))
    elsif pod_name&.length.to_i > K8S_NAME_MAX_LENGTH
      return error(_('pod_name cannot be larger than %{max_length}'\
        ' chars' % { max_length: K8S_NAME_MAX_LENGTH }))
    elsif container_name&.length.to_i > K8S_NAME_MAX_LENGTH
      return error(_('container_name cannot be larger than'\
        ' %{max_length} chars' % { max_length: K8S_NAME_MAX_LENGTH }))
    end

    success(namespace: namespace, pod_name: pod_name, container_name: container_name)
  end

  def pod_logs(result)
    response = cluster.platform.read_pod_logs(
      namespace: result[:namespace],
      pod_name: result[:pod_name],
      container_name: result[:container_name]
    )

    return { status: :processing } unless response

    result.merge!(response.slice(:logs))

    if response[:status] == :error
      error(response[:error]).reverse_merge(result)
    else
      success(result)
    end
  end

  def filter_return_keys(result)
    result.slice(*SUCCESS_RETURN_KEYS)
  end

  def filter_params(params)
    params.slice(*PARAMS)
  end
end
