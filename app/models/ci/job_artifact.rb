# frozen_string_literal: true

module Ci
  class JobArtifact < ApplicationRecord
    include AfterCommitQueue
    include ObjectStorage::BackgroundMove
    include UpdateProjectStatistics
    include Sortable
    extend Gitlab::Ci::Model

    NotSupportedAdapterError = Class.new(StandardError)

    class FileType
      attr_reader :name, :value, :format, :report, :default_file_name
      alias_method :report?, :report

      def initialize(name, value, format, report, default_file_name)
        @name = name
        @value = value
        @format = format
        @report = report
        @default_file_name = default_file_name
      end

      # TODO: remove this method while refactoring
      def [](param)
        public_send(param)
      end

      __ = nil # rubocop: disable Lint/UnderscorePrefixedVariableName
      # All the file types that use `raw` are needed to be stored uncompressed
      # for Frontend to fetch the files and do analysis.
      # When they will be only used by backend, they can be `gzipped`.

      # TODO: maybe make this constant private
      ALL = [
        FileType.new(:archive,             1,   :zip,  __,    __),
        FileType.new(:metadata,            2,   :gzip, __,    __),
        FileType.new(:trace,               3,   :raw,  __,    __),
        FileType.new(:junit,               4,   :gzip, true, 'junit.xml'),
        FileType.new(:sast,                5,   :raw,  true, 'gl-sast-report.json'),
        FileType.new(:dependency_scanning, 6,   :raw,  true, 'gl-dependency-scanning-report.json'),
        FileType.new(:container_scanning,  7,   :raw,  true, 'gl-container-scanning-report.json'),
        FileType.new(:dast,                8,   :raw,  true, 'gl-dast-report.json'),
        FileType.new(:codequality,         9,   :raw,  true, 'gl-code-quality-report.json'),
        FileType.new(:license_management,  10,  :raw,  true, 'gl-license-management-report.json'),
        FileType.new(:license_scanning,    101, :raw,  true, 'gl-license-scanning-report.json'),
        FileType.new(:performance,         11,  :raw,  true, 'performance.json'),
        FileType.new(:metrics,             12,  :gzip, true, 'metrics.txt'),
        FileType.new(:metrics_referee,     13,  :gzip, true, __),
        FileType.new(:network_referee,     14,  :gzip, true, __),
        FileType.new(:lsif,                15,  :gzip, true, 'lsif.json'),
        FileType.new(:dotenv,              16,  :gzip, true, '.env'),
        FileType.new(:cobertura,           17,  :gzip, true, 'cobertura-coverage.xml'),
        FileType.new(:terraform,           18,  :raw,  true, 'tfplan.json')
      ].freeze

      class << self
        def all
          ALL
        end

        def names_and_values
          all.map { |t| [t.name, t.value] }.to_h
        end

        def default_file_name_for(type_name)
          find_file_type(type_name)&.default_file_name
        end

        def format_for(type_name)
          find_file_type(type_name)&.format
        end

        def report_names
          all.select(&:report?).map(&:name)
        end

        def find_file_type(type_name)
          all.find { |type| type.name == type_name.to_sym }
        end
      end
    end

    # TODO: refactor these
    TEST_REPORT_FILE_TYPES = %w[junit].freeze
    COVERAGE_REPORT_FILE_TYPES = %w[cobertura].freeze
    NON_ERASABLE_FILE_TYPES = %w[trace].freeze

    belongs_to :project
    belongs_to :job, class_name: "Ci::Build", foreign_key: :job_id

    mount_uploader :file, JobArtifactUploader

    validates :file_format, presence: true, unless: :trace?, on: :create
    validate :valid_file_format?, unless: :trace?, on: :create
    before_save :set_size, if: :file_changed?

    update_project_statistics project_statistics_name: :build_artifacts_size

    after_save :update_file_store, if: :saved_change_to_file?

    scope :with_files_stored_locally, -> { where(file_store: [nil, ::JobArtifactUploader::Store::LOCAL]) }
    scope :with_files_stored_remotely, -> { where(file_store: ::JobArtifactUploader::Store::REMOTE) }
    scope :for_sha, ->(sha, project_id) { joins(job: :pipeline).where(ci_pipelines: { sha: sha, project_id: project_id }) }
    scope :for_job_name, ->(name) { joins(:job).where(ci_builds: { name: name }) }

    scope :with_file_types, -> (file_types) do
      types = self.file_types.select { |file_type| file_types.include?(file_type) }.values

      where(file_type: types)
    end

    scope :with_reports, -> do
      with_file_types(FileType.report_names.map(&:to_s))
    end

    scope :test_reports, -> do
      with_file_types(TEST_REPORT_FILE_TYPES)
    end

    scope :coverage_reports, -> do
      with_file_types(COVERAGE_REPORT_FILE_TYPES)
    end

    scope :erasable, -> do
      types = self.file_types.reject { |file_type| NON_ERASABLE_FILE_TYPES.include?(file_type) }.values

      where(file_type: types)
    end

    scope :expired, -> (limit) { where('expire_at < ?', Time.now).limit(limit) }

    scope :scoped_project, -> { where('ci_job_artifacts.project_id = projects.id') }

    delegate :filename, :exists?, :open, to: :file

    enum file_type: FileType.names_and_values.freeze

    # TODO: use values from FileType
    enum file_format: {
      raw: 1,
      zip: 2,
      gzip: 3
    }, _suffix: true

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

    # TODO: could be part of FileType class
    FILE_FORMAT_ADAPTERS = {
      gzip: Gitlab::Ci::Build::Artifacts::Adapters::GzipStream,
      raw: Gitlab::Ci::Build::Artifacts::Adapters::RawStream
    }.freeze

    def valid_file_format?
      unless self.file_format&.to_sym == registered_file_type&.format
        errors.add(:base, _('Invalid file format with specified file type'))
      end
    end

    def update_file_store
      # The file.object_store is set during `uploader.store!`
      # which happens after object is inserted/updated
      self.update_column(:file_store, file.object_store)
    end

    def self.default_file_name_for_type(file_type)
      Ci::JobArtifact::FileType.default_file_name_for(file_type)
    end

    def self.format_for_type(file_type)
      Ci::JobArtifact::FileType.format_for(file_type)
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

    def expire_in
      expire_at - Time.now if expire_at
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

    private

    def registered_file_type
      FileType.find_file_type(self.file_type)
    end

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
