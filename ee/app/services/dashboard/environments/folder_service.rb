# frozen_string_literal: true

module Dashboard
  module Environments
    class FolderService
      EnvironmentWithFolderData = Class.new do
        delegate_missing_to :@environment

        def initialize(environment, folder_data)
          @environment = environment
          @folder_data = folder_data
        end

        def size
          folder_data.size
        end

        def within_folder
          folder_data.size > 1 || environment.environment_type.present?
        end

        def raw_environment
          environment
        end

        private

        attr_reader :environment, :folder_data
      end

      # rubocop: disable CodeReuse/ActiveRecord
      def self.execute(environment_relation)
        folders = environment_relation
          .group('COALESCE(environment_type, name)')
          .select('COUNT(id) AS size', 'MAX(id) AS last_id')

        environments_map = environment_relation
          .where(id: folders.map(&:last_id))
          .index_by(&:id)

        folders.map do |folder|
          EnvironmentWithFolderData.new(environments_map[folder.last_id], folder)
        end
      end
      # rubocop: enable CodeReuse/ActiveRecord
    end
  end
end
