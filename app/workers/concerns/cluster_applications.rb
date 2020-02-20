# frozen_string_literal: true

module ClusterApplications
  extend ActiveSupport::Concern

  included do
    def find_application(app_name, id, &blk)
      Clusters::Cluster.application_classes[app_name].find(id).try(&blk)
    end
  end
end
