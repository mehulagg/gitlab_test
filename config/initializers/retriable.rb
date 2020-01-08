# frozen_string_literal: true

Retriable.configure do |config|
  config.contexts[:relation_import] = {
    tries: ENV['max_retries_for_relation_import'] || 3,
    base_interval: 0.1,
    multiplier: 1.0,
    rand_factor: 0.0,
    on: Gitlab::ImportExport::ImportFailureService::RETRIABLE_EXCEPTIONS
  }
end
