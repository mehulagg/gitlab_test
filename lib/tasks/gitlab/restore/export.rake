# frozen_string_literal: true

# @example
#
#   bundle exec rake "gitlab:import_export:export[root, g1, /path/to/file.tar.gz]" # will include repos
namespace :gitlab do
  namespace :restore do
    desc 'GitLab | Import/Export | EXPERIMENTAL | Export large project archives'
    task :export, [:username, :group_path, :export_path] => :gitlab_environment do |_t, args|
      # Load it here to avoid polluting Rake tasks with Sidekiq test warnings
      require 'sidekiq/testing'

      logger = Logger.new($stdout)

      begin
        warn_user_is_not_gitlab

        if ENV['RESTORE_DEBUG'].present?
          Gitlab::Utils::Measuring.logger = logger
          ActiveRecord::Base.logger = logger
          logger.level = Logger::DEBUG
        else
          logger.level = Logger::INFO
        end

        Gitlab::Restore::ExportTask.new(
          group_path: args.group_path,
          username: args.username,
          export_path: args.export_path,
          logger: logger
        ).execute

        exit
      rescue StandardError => e
        logger.error "Exception: #{e.message}"
        logger.debug "---\n#{e.backtrace.join("\n")}"
        exit 1
      end
    end
  end
end
