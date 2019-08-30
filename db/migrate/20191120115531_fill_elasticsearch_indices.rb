# frozen_string_literal: true

class FillElasticsearchIndices < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  class ApplicationSetting < ActiveRecord::Base
    self.table_name = 'application_settings'

    attr_encrypted :elasticsearch_aws_secret_access_key,
      mode: :per_attribute_iv,
      key: Settings.attr_encrypted_db_key_base_truncated,
      algorithm: 'aes-256-gcm',
      encode: true

    def elasticsearch_url
      read_attribute(:elasticsearch_url).to_s.split(',').map(&:strip)
    end

    def elasticsearch_url=(values)
      cleaned = values.split(',').map {|url| url.strip.gsub(%r{/*\z}, '') }

      write_attribute(:elasticsearch_url, cleaned.join(','))
    end
  end

  class ElasticsearchIndex < ActiveRecord::Base
    self.table_name = 'elasticsearch_indices'

    attr_encrypted :aws_secret_access_key,
      mode: :per_attribute_iv,
      key: Settings.attr_encrypted_db_key_base_truncated,
      algorithm: 'aes-256-gcm',
      encode: true
  end

  def up
    return unless ::Gitlab.ee?

    application_setting = ApplicationSetting.first

    return unless application_setting&.elasticsearch_indexing?

    index = ElasticsearchIndex.first_or_initialize
    index.attributes = {
      name:                  'gitlab-production',
      friendly_name:         'Gitlab Production',
      version:               'V12p1',
      urls:                  application_setting.elasticsearch_url,
      aws:                   application_setting.elasticsearch_aws,
      shards:                application_setting.elasticsearch_shards,
      replicas:              application_setting.elasticsearch_replicas,
      aws_region:            application_setting.elasticsearch_aws_region,
      aws_access_key:        application_setting.elasticsearch_aws_access_key,
      aws_secret_access_key: application_setting.elasticsearch_aws_secret_access_key
    }
    index.save!

    if application_setting.elasticsearch_search?
      application_setting.update_column(:elasticsearch_read_index_id, index.id)
    end
  end

  def down
    return unless ::Gitlab.ee?

    application_setting = ApplicationSetting.first

    return unless application_setting
    return unless index = find_index(application_setting)

    application_setting.update!(
      elasticsearch_url:                   index.urls.join(','),
      elasticsearch_aws:                   index.aws,
      elasticsearch_shards:                index.shards,
      elasticsearch_replicas:              index.replicas,
      elasticsearch_aws_region:            index.aws_region,
      elasticsearch_aws_access_key:        index.aws_access_key,
      elasticsearch_aws_secret_access_key: index.aws_secret_access_key
    )

    application_setting.update_column(:elasticsearch_read_index_id, nil)
  end

  private

  def find_index(application_setting)
    if application_setting.elasticsearch_read_index_id
      index = ElasticsearchIndex.find_by(id: application_setting.elasticsearch_read_index_id)
    end

    # Fallback to first write index if read index is absent
    index || ElasticsearchIndex.first
  end
end
