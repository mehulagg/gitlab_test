# frozen_string_literal: true

class PrometheusHealthCheckWorker
  include ApplicationWorker
  idempotent!

  def perform(cluster_id)
  end
end
