# frozen_string_literal: true

class PodLogsService < ::BaseService
  include Stepable

  attr_reader :cluster

  K8S_NAME_MAX_LENGTH = 253

  PARAMS = %w(namespace pod container).freeze

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
    pod = params['pod'].presence
    container = params['container'].presence

    if namespace&.length.to_i > K8S_NAME_MAX_LENGTH
      return error(_('namespace cannot be larger than %{max_length}'\
        ' chars' % { max_length: K8S_NAME_MAX_LENGTH }))
    elsif pod&.length.to_i > K8S_NAME_MAX_LENGTH
      return error(_('pod cannot be larger than %{max_length}'\
        ' chars' % { max_length: K8S_NAME_MAX_LENGTH }))
    elsif container&.length.to_i > K8S_NAME_MAX_LENGTH
      return error(_('container cannot be larger than'\
        ' %{max_length} chars' % { max_length: K8S_NAME_MAX_LENGTH }))
    end

    success(namespace: namespace, pod: pod, container: container)
  end

  def pod_logs(result)
    response = cluster.platform.read_pod_logs(
      namespace: result[:namespace],
      pod: result[:pod],
      container: result[:container]
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
