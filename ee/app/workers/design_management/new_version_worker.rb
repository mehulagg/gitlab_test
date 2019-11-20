# frozen_string_literal: true

module DesignManagement
  class NewVersionWorker
    include ApplicationWorker

    feature_category :design_management

    def perform(version_id)
      version = DesignManagement::Version.find(version_id)

      add_system_note(version)
      generate_image_versions(version)
    rescue ActiveRecord::RecordNotFound => e
      Sidekiq.logger.warn(e)
    end

    private

    def add_system_note(version)
      SystemNoteService.design_version_added(version)
    end

    def generate_image_versions(version)
      # TODO new service.
      # The service would look like:
      #
      # lfs_objects = find_lfs_objects_in_version(version)
      #
      # lfs_objects.each do |lfs_object|
      #   lfs_object.file.enable_version_namespace(:design_management)
      #   lfs_object.file.recreate_versions!
      # end
    end
  end
end
