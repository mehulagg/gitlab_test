# frozen_string_literal: true

module Gitlab
  module ImportExport
    class ImportFailureService
      def initialize(importable)
        self.importable = importable
      end

      def with_retry(relation_key, relation_index)
        retry_count = 0
        retry_exception = nil

        on_retry = proc do |exception, retry_number|
          retry_count = retry_number
          retry_exception = exception
        end

        Retriable.with_context(:relation_import, on_retry: on_retry) do
          yield
        end
      rescue ActiveRecord::StatementInvalid, GRPC::DeadlineExceeded => e
        log_import_failure(relation_key, relation_index, e, retry_count, ImportFailure.retry_statuses[:failed])
      else
        log_import_failure(relation_key, relation_index, retry_exception, retry_count, ImportFailure.retry_statuses[:success]) if retry_count > 0
      end

      def log_import_failure(relation_key, relation_index, exception, retry_count = 0, retry_status = 0)
        extra = { project_id: importable.id, relation_key: relation_key, relation_index: relation_index }
        extra = extra.merge(retry_count: retry_count, retry_status: ImportFailure.retry_statuses.key(retry_status)) if retry_count.to_i > 0
        Gitlab::ErrorTracking.track_exception(exception, extra)

        ImportFailure.create(
          project: importable,
          relation_key: relation_key,
          relation_index: relation_index,
          exception_class: exception.class.to_s,
          retry_count: retry_count,
          retry_status: retry_status,
          exception_message: exception.message.truncate(255),
          correlation_id_value: Labkit::Correlation::CorrelationId.current_or_new_id)
      end

      private

      attr_accessor :importable
    end
  end
end
