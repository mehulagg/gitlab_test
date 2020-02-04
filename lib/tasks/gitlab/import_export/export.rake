# frozen_string_literal: true

namespace :gitlab do
  namespace :import_export do
    desc 'GitLab | Import/Export | EXPERIMENTAL | Export large project archives'
    task :export, [:username, :namespace_path, :project_path, :archive_path] => :gitlab_environment do |_t, args|
      # Load it here to avoid polluting Rake tasks with Sidekiq test warnings
      require 'sidekiq/testing'

      sleep(15)

      class CopyFileStrategy < Gitlab::ImportExport::AfterExportStrategies::BaseAfterExportStrategy
        def initialize(archive_path:)
          @archive_path = archive_path
        end

        private

        def strategy_execute
          FileUtils.mv(project.export_file.path, @archive_path)
        end
      end

      warn_user_is_not_gitlab

      if ENV['IMPORT_DEBUG'].present?
        ActiveRecord::Base.logger = Logger.new(STDOUT)
        Gitlab::Metrics::Exporter::SidekiqExporter.instance.start
      end

      def with_count_queries(&block)
        count = 0

        counter_f = ->(name, started, finished, unique_id, payload) {
          unless payload[:name].in? %w[ CACHE SCHEMA ]
            count += 1
          end
        }

        ActiveSupport::Notifications.subscribed(counter_f, "sql.active_record", &block)

        puts "Number of SQL calls: #{count}"
      end

      def with_measuretime
        timing = Benchmark.realtime do
          yield
        end
        puts "Time to finish: #{timing}"
      end

      current_user = User.find_by_username(args.username)
      namespace = Namespace.find_by_full_path(args.namespace_path)
      project = namespace.projects.find_by_path(args.project_path)

      with_count_queries do
        with_measuretime do
          ::Projects::ImportExport::ExportService.new(project, current_user)
            .execute(CopyFileStrategy.new(archive_path: args.archive_path))
        end
      end

      puts "Memory usage: #{Gitlab::Metrics::System.memory_usage.to_f / 1024 / 1024} MiB"
      puts "GC calls: #{GC.stat[:count]}"
      puts "GC major calls: #{GC.stat[:major_gc_count]}"
      puts "Label: #{Prometheus::PidProvider.worker_id}"

      sleep(30)

      puts 'Done!'
    rescue StandardError => e
      puts "Exception: #{e.message}"
      puts e.backtrace
      exit 1
    end
  end
end

class GitlabProjectImport
  def initialize(opts)
    @project_path = opts.fetch(:project_path)
    @file_path    = opts.fetch(:file_path)
    @namespace    = Namespace.find_by_full_path(opts.fetch(:namespace_path))
    @current_user = User.find_by_username(opts.fetch(:username))
  end

  def import
    show_import_start_message

    run_isolated_sidekiq_job

    show_import_failures_count

    if @project&.import_state&.last_error
      puts "ERROR: #{@project.import_state.last_error}"
      exit 1
    elsif @project.errors.any?
      puts "ERROR: #{@project.errors.full_messages.join(', ')}"
      exit 1
    else
      puts 'Done!'
    end
  rescue StandardError => e
    puts "Exception: #{e.message}"
    puts e.backtrace
    exit 1
  end

  private

  def with_request_store
    RequestStore.begin!
    yield
  ensure
    RequestStore.end!
    RequestStore.clear!
  end

  # We want to ensure that all Sidekiq jobs are executed
  # synchronously as part of that process.
  # This ensures that all expensive operations do not escape
  # to general Sidekiq clusters/nodes.
  def run_isolated_sidekiq_job
    Sidekiq::Testing.fake! do
      with_request_store do
        @project = create_project

        execute_sidekiq_job
      end
      true
    end
  end

  def create_project
    # We are disabling ObjectStorage for `import`
    # as it is too slow to handle big archives:
    # 1. DB transaction timeouts on upload
    # 2. Download of archive before unpacking
    disable_upload_object_storage do
      service = Projects::GitlabProjectsImportService.new(
        @current_user,
        {
          namespace_id: @namespace.id,
          path:         @project_path,
          file:         File.open(@file_path)
        }
      )

      service.execute
    end
  end

  def execute_sidekiq_job
    Sidekiq::Worker.drain_all
  end

  def disable_upload_object_storage
    overwrite_uploads_setting('background_upload', false) do
      overwrite_uploads_setting('direct_upload', false) do
        yield
      end
    end
  end

  def overwrite_uploads_setting(key, value)
    old_value = Settings.uploads.object_store[key]
    Settings.uploads.object_store[key] = value

    yield

  ensure
    Settings.uploads.object_store[key] = old_value
  end

  def full_path
    "#{@namespace.full_path}/#{@project_path}"
  end

  def show_import_start_message
    puts "Importing GitLab export: #{@file_path} into GitLab" \
      " #{full_path}" \
      " as #{@current_user.name}"
  end

  def show_import_failures_count
    return unless @project.import_failures.exists?

    puts "Total number of not imported relations: #{@project.import_failures.count}"
  end
end
