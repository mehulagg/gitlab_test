# frozen_string_literal: true

# Worker which will try to find storage shard systems with 
# disk usage over a configured threshold, and trigger either
# a logging alert or an automatic storage re-balance procedure.
class DetectHighDiskUsageWorker
  include ApplicationWorker

  feature_category :source_code_management

  LEASE_TIMEOUT = 300

  # rubocop: disable CodeReuse/ActiveRecord
  def perform()
    ::Servers::DetectHighDiskUsageService.new.execute
  end
  # rubocop: enable CodeReuse/ActiveRecord

  private

  def lease_timeout
    LEASE_TIMEOUT
  end

  def lease_key
    "gitlab:detect_storage_shards_with_high_disk_usage"
  end
end
