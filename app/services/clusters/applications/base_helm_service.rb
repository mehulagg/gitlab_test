# frozen_string_literal: true

module Clusters
  module Applications
    class BaseHelmService
      attr_accessor :app

      ERROR_TRANSLATIONS = {
        install: _('Failed to install.'),
        patch: _('Failed to update.'),
        upgrade: _('Failed to upgrade.'),
        uninstall: _('Failed to uninstall.')
      }.freeze

      def initialize(app)
        @app = app
      end

      protected

      def issue_helm_command(command, worker:)
        log_event("begin_#{command}")

        yield

        log_event("schedule_wait_for_#{command}")
        worker.perform_in(worker::INTERVAL, app.name, app.id)

      rescue Kubeclient::HttpError => e
        log_error(e)
        app.make_errored!(_('Kubernetes error: %{error_code}') % { error_code: e.error_code })
      rescue StandardError => e
        log_error(e)
        app.make_errored!(ERROR_TRANSLATIONS[command])
      end

      def log_error(error)
        meta = {
          error_code: error.respond_to?(:error_code) ? error.error_code : nil,
          service: self.class.name,
          app_id: app.id,
          app_name: app.name,
          project_ids: app.cluster.project_ids,
          group_ids: app.cluster.group_ids
        }

        logger_meta = meta.merge(
          exception: error.class.name,
          message: error.message,
          backtrace: Gitlab::Profiler.clean_backtrace(error.backtrace)
        )

        logger.error(logger_meta)
        Gitlab::Sentry.track_acceptable_exception(error, extra: meta)
      end

      def log_event(event)
        meta = {
          service: self.class.name,
          app_id: app.id,
          app_name: app.name,
          project_ids: app.cluster.project_ids,
          group_ids: app.cluster.group_ids,
          event: event
        }

        logger.info(meta)
      end

      def logger
        @logger ||= Gitlab::Kubernetes::Logger.build
      end

      def cluster
        app.cluster
      end

      def kubeclient
        cluster.kubeclient
      end

      def helm_api
        @helm_api ||= Gitlab::Kubernetes::Helm::Api.new(kubeclient)
      end

      def install_command
        @install_command ||= app.install_command
      end

      def update_command
        @update_command ||= app.update_command
      end

      def upgrade_command(new_values = "")
        app.upgrade_command(new_values)
      end
    end
  end
end
