# frozen_string_literal: true

module Ci
  class JobArtifact < ApplicationRecord
    include AfterCommitQueue
    include ObjectStorage::BackgroundMove
    include UpdateProjectStatistics
    include UsageStatistics
    include Sortable
    include IgnorableColumns
    include ::Ci::Artifacts::Definiable
    extend Gitlab::Ci::Model

    NotSupportedAdapterError = Class.new(StandardError)

    ignore_columns :locked, remove_after: '2020-07-22', remove_with: '13.4'

    PLAN_LIMIT_PREFIX = 'ci_max_artifact_size_'

    belongs_to :project
    belongs_to :job, class_name: "Ci::Build", foreign_key: :job_id

    mount_uploader :file, JobArtifactUploader

    validates :file_format, presence: true, unless: :trace?, on: :create
    validate :validate_supported_file_format!, on: :create
    validate :validate_file_format!, unless: :trace?, on: :create
    before_save :set_size, if: :file_changed?

    update_project_statistics project_statistics_name: :build_artifacts_size

    after_save :update_file_store, if: :saved_change_to_file?

    scope :not_expired, -> { where('expire_at IS NULL OR expire_at > ?', Time.current) }
    scope :with_files_stored_locally, -> { where(file_store: ::JobArtifactUploader::Store::LOCAL) }
    scope :with_files_stored_remotely, -> { where(file_store: ::JobArtifactUploader::Store::REMOTE) }
    scope :for_sha, ->(sha, project_id) { joins(job: :pipeline).where(ci_pipelines: { sha: sha, project_id: project_id }) }
    scope :for_job_name, ->(name) { joins(:job).where(ci_builds: { name: name }) }

    scope :with_file_types, -> (file_types) do
      types = self.file_types.select { |file_type| file_types.include?(file_type) }.values

      where(file_type: types)
    end

    scope :with_reports, -> do
      with_defined_tags(:report)
    end

    scope :test_reports, -> do
      with_defined_tags(:report, :test)
    end

    scope :accessibility_reports, -> do
      with_defined_tags(:report, :accessibility)
    end

    scope :coverage_reports, -> do
      with_defined_tags(:report, :coverage)
    end

    scope :terraform_reports, -> do
      with_defined_tags(:report, :terraform)
    end

    scope :erasable, -> do
      with_defined_options(:erasable)
    end

    scope :expired, -> (limit) { where('expire_at < ?', Time.current).limit(limit) }
    scope :downloadable, -> { with_defined_options(:downloadable) }
    scope :unlocked, -> { joins(job: :pipeline).merge(::Ci::Pipeline.unlocked).order(expire_at: :desc) }

    scope :scoped_project, -> { where('ci_job_artifacts.project_id = projects.id') }

    delegate :filename, :exists?, :open, to: :file

    # `file_location` indicates where actual files are stored.
    # Ideally, actual files should be stored in the same directory, and use the same
    # convention to generate its path. However, sometimes we can't do so due to backward-compatibility.
    #
    # legacy_path ... The actual file is stored at a path consists of a timestamp
    #                 and raw project/model IDs. Those rows were migrated from
    #                 `ci_builds.artifacts_file` and `ci_builds.artifacts_metadata`
    # hashed_path ... The actual file is stored at a path consists of a SHA2 based on the project ID.
    #                 This is the default value.
    enum file_location: {
      legacy_path: 1,
      hashed_path: 2
    }

    FILE_FORMAT_ADAPTERS = {
      gzip: Gitlab::Ci::Build::Artifacts::Adapters::GzipStream,
      raw: Gitlab::Ci::Build::Artifacts::Adapters::RawStream
    }.freeze

    def validate_supported_file_format!
      return if Feature.disabled?(:drop_license_management_artifact, project, default_enabled: true)

      if Gitlab::Ci::Build::Artifacts::Definitions.get(self.file_type&.to_sym)&.unsupported?
        errors.add(:base, _("File format is no longer supported"))
      end
    end

    def validate_file_format!
      unless Gitlab::Ci::Build::Artifacts::Definitions.get(self.file_type&.to_sym)&.file_format == self.file_format&.to_sym
        errors.add(:base, _('Invalid file format with specified file type'))
      end
    end

    def update_file_store
      # The file.object_store is set during `uploader.store!`
      # which happens after object is inserted/updated
      self.update_column(:file_store, file.object_store)
    end

    def self.associated_file_types_for(file_type)
      return unless file_types.include?(file_type)

      [file_type]
    end

    def self.total_size
      self.sum(:size)
    end

    def self.artifacts_size_for(project)
      self.where(project: project).sum(:size)
    end

    def local_store?
      [nil, ::JobArtifactUploader::Store::LOCAL].include?(self.file_store)
    end

    def hashed_path?
      return true if trace? # ArchiveLegacyTraces background migration might not have `file_location` column

      super || self.file_location.nil?
    end

    def expired?
      expire_at.present? && expire_at < Time.current
    end

    def expiring?
      expire_at.present? && expire_at > Time.current
    end

    def expire_in
      expire_at - Time.current if expire_at
    end

    def expire_in=(value)
      self.expire_at =
        if value
          ChronicDuration.parse(value)&.seconds&.from_now
        end
    end

    def each_blob(&blk)
      unless file_format_adapter_class
        raise NotSupportedAdapterError, 'This file format requires a dedicated adapter'
      end

      file.open do |stream|
        file_format_adapter_class.new(stream).each_blob(&blk)
      end
    end

    def self.archived_trace_exists_for?(job_id)
      where(job_id: job_id).trace.take&.file&.file&.exists?
    end

    def self.max_artifact_size(type:, project:)
      limit_name = "#{PLAN_LIMIT_PREFIX}#{type}"

      max_size = project.actual_limits.limit_for(
        limit_name,
        alternate_limit: -> { project.closest_setting(:max_artifacts_size) }
      )

      max_size&.megabytes.to_i
    end

    private

    def file_format_adapter_class
      FILE_FORMAT_ADAPTERS[file_format.to_sym]
    end

    def set_size
      self.size = file.size
    end

    def project_destroyed?
      # Use job.project to avoid extra DB query for project
      job.project.pending_delete?
    end
  end
end

Ci::JobArtifact.prepend_if_ee('EE::Ci::JobArtifact')
