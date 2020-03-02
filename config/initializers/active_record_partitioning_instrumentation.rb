ActiveRecord::ConnectionAdapters::AbstractAdapter.module_eval do
  include Gitlab::Database::PartitionAwareInstrumentation
end
