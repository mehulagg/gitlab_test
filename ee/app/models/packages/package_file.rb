# frozen_string_literal: true
class Packages::PackageFile < ApplicationRecord
  include UpdateProjectStatistics
  include ::Gitlab::Geo::ReplicableModel

  delegate :project, :project_id, to: :package
  delegate :conan_file_type, to: :conan_file_metadatum

  belongs_to :package

  has_one :conan_file_metadatum, inverse_of: :package_file, class_name: 'Packages::Conan::FileMetadatum'

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
      .where(packages_conan_file_metadata: { conan_file_type: ::Packages::Conan::FileMetadatum.conan_file_types[file_type] })
  end

  scope :with_conan_package_reference, ->(conan_package_reference) do
    joins(:conan_file_metadatum)
      .where(packages_conan_file_metadata: { conan_package_reference: conan_package_reference })
  end

  mount_uploader :file, Packages::PackageFileUploader

  with_replicator Geo::PackageFileReplicator

  after_save :update_file_metadata, if: :saved_change_to_file?

  update_project_statistics project_statistics_name: :packages_size

  def self.replicables_for_geo_node
    return self.all unless Gitlab::Geo.current_node.selective_sync?

    query = ::Packages::Package.where(project_id: Gitlab::Geo.current_node.projects).select(:id)
    cte = Gitlab::SQL::CTE.new(:restricted_packages, query)
    replicable_table = self.arel_table

    inner_join_restricted_packages =
      cte.table
        .join(replicable_table, Arel::Nodes::InnerJoin)
        .on(cte.table[:id].eq(replicable_table[:package_id]))
        .join_sources

    self
      .with(cte.to_arel)
      .from(cte.table)
      .joins(inner_join_restricted_packages)
  end

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

  def local?
    file_store == ::Packages::PackageFileUploader::Store::LOCAL
  end
end
