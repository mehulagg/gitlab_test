# frozen_string_literal: true

require 'csv'

class ElasticsearchIndex < ApplicationRecord
  LATEST_VERSION = 'V12p1'.freeze

  include Sortable

  validates :name, :friendly_name, :version, :shards, :replicas, presence: true
  validates :name, :friendly_name, uniqueness: { case_sensitive: false }
  validates :shards, :replicas, numericality: { only_integer: true, greater_than: 0 }

  validates :urls, length: { minimum: 1, message: :blank }
  validates :urls, length: { maximum: 1000, message: _('is too long (maximum is 1000 entries)') }
  validate :validate_addressable_urls

  validates :aws_region,
    presence: { message: _("can't be blank when using AWS hosted Elasticsearch") },
    if: :aws?

  attr_readonly :name, :version, :shards, :replicas

  attr_encrypted :aws_secret_access_key,
    mode: :per_attribute_iv,
    key: Settings.attr_encrypted_db_key_base_truncated,
    algorithm: 'aes-256-gcm',
    encode: true

  before_validation :set_version
  before_validation :build_name

  def urls=(values)
    values = values.split(',') if values.is_a?(String)
    values = values.map { |url| url.strip.gsub(%r{/*\z}, '') }

    super(values)
  end

  def connection_config
    slice(:urls, :aws, :aws_access_key, :aws_secret_access_key, :aws_region).symbolize_keys
  end

  def client
    ::Gitlab::Elastic::Client.cached(self)
  end

  private

  def validate_addressable_urls
    return unless urls.present?

    validator = AddressableUrlValidator.new(attributes: [:urls])

    urls.each do |url|
      validator.validate_each(self, :urls, url)
    end
  end

  def set_version
    self.version ||= LATEST_VERSION
  end

  def build_name
    return unless version?

    # Allow multiple indices with the same version, by adding a random string
    salt = SecureRandom.hex(4)

    self.name ||= [Rails.application.class.parent_name.downcase, Rails.env, version.downcase, salt].join('-')
  end
end
