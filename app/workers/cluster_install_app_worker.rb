# frozen_string_literal: true

class ClusterInstallAppWorker
  include ApplicationWorker
  include ClusterQueue
  include ClusterApplications

  worker_has_external_dependencies!

  def perform(app_name, app_id)
    find_application(app_name, app_id) do |app|
      Clusters::Applications::InstallService.new(app).execute #First step to be performed by the background job
    end
  end
end
