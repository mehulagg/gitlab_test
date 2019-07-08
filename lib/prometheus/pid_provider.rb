# frozen_string_literal: true

module Prometheus::PidProvider
  extend self

  def worker_id
    if Sidekiq.server?
      'sidekiq'
    elsif defined?(Unicorn::Worker)
      "unicorn_#{prometheus_unicorn_worker_id}"
    elsif defined?(::Puma)
      "puma_#{prometheus_puma_worker_id}"
    else
      "process_#{Process.pid}"
    end
  end

  private

  def prometheus_unicorn_worker_id
    ::Prometheus::Client::Support::Unicorn.worker_id || 'master'
  end

  def prometheus_puma_worker_id
    match = $0.match(/cluster worker ([0-9]+):/)
    match ? match[1] : 'master'
  end
end
