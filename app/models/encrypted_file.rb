# frozen_string_literal: true

class EncryptedFileUploader < GitlabUploader
  include ObjectStorage::Concern

  storage_options Gitlab.config.uploads

  before :cache, :ensure_key

  encrypt(key: :key)

  delegate :key, :ensure_key, to: :model

  def filename
    "state-1"
  end

  def store_dir
    'tf-state'
  end
end

class EncryptedFile < ApplicationRecord
  encrypts :key, type: :string, key: Gitlab::Application.secrets.db_key_base[0..63]

  mount_uploader :file, EncryptedFileUploader

  def ensure_key(_)
    self.key ||= Lockbox.generate_key
  end
end