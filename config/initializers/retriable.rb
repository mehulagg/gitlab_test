# frozen_string_literal: true

Retriable.configure do |config|
  config.contexts[:relation_import] = {
    tries: 3,
    base_interval: 0.1,
    multiplier: 1.0,
    rand_factor: 0.0,
    on: [
      ActiveRecord::StatementInvalid,
      GRPC::DeadlineExceeded
    ]
  }
end
