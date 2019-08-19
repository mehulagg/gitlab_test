# frozen_string_literal: true

class EnvironmentsWithinFoldersFinder
  class EnvironmentWithFolderData
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
    environments_table = Environment.arel_table

    folders = environment_relation
      .group('COALESCE(environment_type, name)')
      .select(environments_table[:id].count.as('size'), environments_table[:id].maximum.as('last_id'))

    environments_map = environment_relation
      .where(id: folders.map(&:last_id))
      .index_by(&:id)

    folders.map do |folder|
      EnvironmentWithFolderData.new(environments_map[folder.last_id], folder)
    end
  end
  # rubocop: enable CodeReuse/ActiveRecord
end
