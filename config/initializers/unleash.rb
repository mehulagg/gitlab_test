# frozen_string_literal: true

return if Settings.feature_flags.unleash['url'].nil? ||
          Settings.feature_flags.unleash['instance_id'].nil? ||
          Settings.feature_flags.unleash['enabled'] != true ||
          Rails.env.test?

def configure_client
  options = Settings.feature_flags.unleash
  ::Unleash.configure do |config|
    config.url = options['url']
    config.instance_id = options['instance_id']
    config.app_name = options['app_name'] || Rails.env
    config.disable_client = false

    config.log_level =
      begin
        Logger::Severity.const_get(options['log_level'].upcase, false)
      rescue NameError
        Logger::INFO
      end

    config.logger = Gitlab::Unleash::Logger.build
    config.disable_metrics = options['disable_metrics']
    config.metrics_interval = options['metrics_interval']
    config.refresh_interval = options['refresh_interval']
    config.retry_limit = options['retry_limit']
    config.timeout = options['timeout']
  end
end

def build_client
  configure_client

  # Note that Unleash::Client#new makes a HTTP call, placing it behind
  # a lazy evaluation defers this until the client is first used.
  # Also the ToggleFetcher and possibly the MetricsReporter threads
  # will start up and periodically make HTTP calls.
  #
  # In local testing/development this is useful because often your
  # gitlab instance will be self hosting its own unleash flags,
  # so this works around a race condition between having that server
  # come up and attempting to register a client with it.
  #
  # In Production it simply allows you to not have to pay for what
  # you don't use.
  Gitlab::Lazy.new { ::Unleash::Client.new }
end

Gitlab::Cluster::LifecycleEvents.on_worker_start do
  Rails.configuration.unleash = build_client
end

Gitlab::Cluster::LifecycleEvents.on_before_graceful_shutdown do
  Rails.configuration.unleash.shutdown!
end
