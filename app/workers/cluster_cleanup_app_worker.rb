# frozen_string_literal: true

# This worker asynchronously uninstalls all the Clusters::Applications. It
# reschedules itself to check if those applications have already succeded or
# failed. If succeded, it tries to uninstall other applications that could be
# dependending on the first ones. Finally, if some applications could not be
# uninstalled after EXECUTION_LIMIT amount of executions, it
# sets the cluster.cleanup_status as errored.

class ClusterCleanupAppWorker < ClusterCleanupWorkerBase
  include ApplicationWorker
  include ClusterQueue

  def perform(cluster_id, execution_count = 0)
    super(cluster_id, execution_count)

    return unless cluster.uninstalling_applications?

    return exceeded_execution_limit if exceeded_execution_limit?

    persisted_applications = @cluster.persisted_applications

    persisted_available_applications = persisted_applications.select(&:available?)

    if persisted_available_applications.present?
      persisted_available_applications.each do |app|
        next unless app.can_uninstall? && app.available?

        log_event(:uninstalling_app, application: app.class.application_name)

        uninstall_app_async(app)
      end

      return schedule_next_execution
    end

    # This is necessary in case the only applications left are stil in a
    # not uninstallable state (scheduled|uninstalling). So we give more time
    # for them to finish their uninstallation.
    return schedule_next_execution if persisted_applications.any?(:transitioning?)

    log_event(:schedule_remove_project_namespaces)

    cluster.continue_cleanup!
  end

  private

  def cluster
    @cluster ||= Clusters::Cluster.with_persisted_applications.find_by_id(@cluster_id)
  end

  def uninstall_app_async(application)
    application.make_scheduled!

    Clusters::Applications::UninstallService.new(application).execute
  end
end
