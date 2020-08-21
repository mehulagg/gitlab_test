# frozen_string_literal: true

module ImportExport
  class ImportService
    IMPORT_HANDLERS = {
      # project: ProjectImportWorker,
      # group: GroupImportWorker
    }.freeze

    attr_reader :type, :id

    def initialize(importable_type:, importable_id:)
      @type = importable_type.to_sym
      @id = importable_id
    end

    def async_execute
      ImportWorker.perform_async(importable_type, importable_id)
    end

    def execute
      # download the export file

      # generate the right import location

      # call the right importer
      importer_class.perform_async(args)
    end

    private

    def importer_class
      IMPORT_HANDLERS.fetch(type)
    end

    def args
      case type
      when :project
        project_args
      when :group
        group_args
      else
        raise 'Unknown importable type'
      end
    end

    def project_args
      {

      }
    end

    def group_args
      {

      }
    end
  end
end
