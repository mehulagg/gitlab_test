# frozen_string_literal: true

class ElasticIndexerWorker
  include ApplicationWorker

  sidekiq_options retry: 2
  feature_category :search

  def perform(operation, class_name, record_id, es_id, options = {})
    return true unless Gitlab::CurrentSettings.elasticsearch_indexing?

    klass = class_name.constantize

    case operation.to_s
    when /index|update/
      Elastic::IndexRecordService.new.execute(
        klass.find(record_id),
        operation.to_s.match?(/index/),
        options
      )
    when /delete/
      if klass == Project
        klass.__elasticsearch__.delete_child_documents(es_id, record_id)
        IndexStatus.for_project(record_id).delete_all
      end

      klass.__elasticsearch__.delete_document(es_id, options['es_parent'])
    end
  rescue Elasticsearch::Transport::Transport::Errors::NotFound, ActiveRecord::RecordNotFound => e
    # These errors can happen in several cases, including:
    # - A record is updated, then removed before the update is handled
    # - Indexing is enabled, but not every item has been indexed yet - updating
    #   and deleting the un-indexed records will raise exception
    #
    # We can ignore these.

    logger.error(message: 'elastic_indexer_worker_caught_exception', error_class: e.class.name, error_message: e.message)

    true
  end

  private

  def logger
    @logger ||= ::Gitlab::Elasticsearch::Logger.build
  end
end
