# frozen_string_literal: true
class Packages::PackageFile < ApplicationRecord
  include UpdateProjectStatistics
  include ::Gitlab::Geo::ReplicableModel
  include IgnorableColumns
  include Checksummable

  ignore_column :file_type, remove_with: '12.10', remove_after: '2019-03-22'

  delegate :project, :project_id, to: :package
  delegate :conan_file_type, to: :conan_file_metadatum

  belongs_to :package

  has_one :conan_file_metadatum, inverse_of: :package_file

  accepts_nested_attributes_for :conan_file_metadatum

  validates :package, presence: true
  validates :file, presence: true
  validates :file_name, presence: true

  scope :recent, -> { order(id: :desc) }
  scope :with_file_name, ->(file_name) { where(file_name: file_name) }
  scope :with_file_name_like, ->(file_name) { where(arel_table[:file_name].matches(file_name)) }
  scope :with_files_stored_locally, -> { where(file_store: ::Packages::PackageFileUploader::Store::LOCAL) }
  scope :with_conan_file_metadata, -> { includes(:conan_file_metadatum) }

  scope :with_conan_file_type, ->(file_type) do
    joins(:conan_file_metadatum)
      .where(packages_conan_file_metadata: { conan_file_type: ::Packages::ConanFileMetadatum.conan_file_types[file_type] })
  end

  mount_uploader :file, Packages::PackageFileUploader

  with_replicator Geo::PackageFileReplicator

  after_save :update_file_metadata, if: :saved_change_to_file?
  after_create_commit -> { replicator.handle_after_create_commit }

  update_project_statistics project_statistics_name: :packages_size

  def update_file_metadata
    # The file.object_store is set during `uploader.store!`
    # which happens after object is inserted/updated
    self.update_column(:file_store, file.object_store)
    self.update_column(:size, file.size) unless file.size == self.size
  end

  def log_geo_deleted_event
    # Keep empty for now. Should be addressed in future
    # by https://gitlab.com/gitlab-org/gitlab/issues/7891
  end

  def download_path
    Gitlab::Routing.url_helpers.download_project_package_file_path(project, self)
  end

  def calculate_checksum!
    self.verification_checksum = nil
    return unless needs_checksum?

    self.verification_checksum = self.class.hexdigest(absolute_path)
  end

  def needs_checksum?
    verification_checksum.nil? && local? && exist?
  end

  def local?
    file_store == ::Packages::PackageFileUploader::Store::LOCAL
  end

  # This checks for existence of the upload on storage
  #
  # @return [Boolean] whether upload exists on storage
  def exist?
    if local?
      File.exist?(absolute_path)
    else
      file.exists?
    end
  end

  def absolute_path
    raise ObjectStorage::RemoteStoreError, _("Remote object has no absolute path.") unless local?

    Packages::PackageFileUploader.absolute_path(self)
  end
end
