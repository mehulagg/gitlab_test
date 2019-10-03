# frozen_string_literal: true

require 'csv'

class ElasticsearchIndex < ApplicationRecord
  validates :shards, :replicas, :name, :friendly_name, :version, presence: true
  validates :shards, :replicas, numericality: { only_integer: true, greater_than: 0 }
  validates :name, :friendly_name, uniqueness: true
  validates :aws_region,
    presence: { message: _("can't be blank when using AWS hosted Elasticsearch") },
    if: :aws?
  validates :urls,
    qualified_domain_array: true,
    length: { maximum: 1_000, message: N_('is too long (maximum is 1000 entries)') }

  attr_readonly :shards, :replicas

  attr_encrypted :aws_secret_access_key,
    mode: :per_attribute_iv,
    key: Settings.attr_encrypted_db_key_base_truncated,
    algorithm: 'aes-256-gcm',
    encode: true

  def urls_as_csv
    urls.to_csv(row_sep: nil)
  end

  def urls_as_csv=(values)
    self.urls = values.parse_csv.map {|url| url.strip.gsub(%r{/*\z}, '') }
  end

  def connection_config
    slice(:urls, :aws, :aws_access_key, :aws_secret_access_key, :aws_region).symbolize_keys
  end

  def client
    ::Gitlab::Elastic::Client.cached(self)
  end
end
