# frozen_string_literal: true

module EE
  module ObjectStorage
    module Concern
      extend ActiveSupport::Concern

      included do
        after :migrate, :log_geo_deleted_event
      end

      private

      def log_geo_deleted_event(_migrated_file)
        upload.replicator.publish :deleted
      end
    end
  end
end
