# frozen_string_literal: true

class ElasticAssociationIndexerWorker
  include ApplicationWorker

  feature_category :search
  sidekiq_options retry: 2

  RETRY_BATCH_SIZES = [100, 10, 1].freeze

  def perform(project_id, association_name, batch_size = nil, ids = nil)
    project = Project.find(project_id)

    _, association = project.each_indexed_association.find { |k, _| k == association_name.to_s.classify.constantize }

    options = {
      return: 'errors'
    }

    options[:batch_size] = batch_size if batch_size

    errors = if ids
               association.id_in(ids).es_import(options)
             else
               association.es_import(options)
             end

    return if errors.empty?

    if ids
      raise Elastic::IndexRecordService::ImportError.new(errors.inspect)
    else
      self.class.perform_async(project_id, association_name, nil, extract_ids(errors))
    end
  rescue Faraday::TimeoutError => e
    retry_index = RETRY_BATCH_SIZES.index(batch_size)
    next_batch_size = if retry_index
                        RETRY_BATCH_SIZES[retry_index + 1]
                      else
                        RETRY_BATCH_SIZES.first
                      end

    raise e unless next_batch_size

    self.class.perform_async(project_id, association_name, next_batch_size)
  end

  private

  def extract_ids(errors)
    errors.map { |error| error['index']['_id'][/_(\d+)$/, 1].to_i }
  end
end
