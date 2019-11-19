# frozen_string_literal: true

module Gitlab
  module ImportExport
    class VersionManager

      def self.import_manager_klass_for_version(version)
        new(version: version).versioned_klass(ImportManager.to_s)
      end

      def self.export_manager_klass_for_version(version)
        new(version: version).versioned_klass(ExportManager.to_s)
      end

      def self.check(version)
        new(version: version).verify_version
      end

      def initialize(version: ImportExport.version)
        @version = version
      end

      # check for klass in proper version module (V0_2_4), if not found, fallback to default (Gitlab::ImportExport)
      def versioned_klass(klass_name)
        if version_module.const_defined?(klass_name)
          version_module.const_get(klass_name, false)
        else
          Gitlab::ImportExport.const_get(klass_name, false)
        end
      rescue NameError => error
        Rails.logger.error("Import/Export error: #{error.message}") # rubocop:disable Gitlab/RailsLogger
      end

      private

      def version_module
        @version_module ||= begin
          if Gitlab::ImportExport.const_defined?(version_klass_name)
            Gitlab::ImportExport.const_get(version_klass_name, false)
          else
            raise Gitlab::ImportExport::Error.new("Import version #{version} not supported.")
          end
        end
      end

      def version_klass_name
        @version_klass_name ||= "V#{version.gsub(/\.{1}/, '_')}"
      end

      def verify_version
        if version_supported?
          true
        else
          raise Gitlab::ImportExport::Error.new("Version not supported: #{version}. Latest supported version: #{Gitlab::ImportExport.version}")
        end
      end

      def version_supported?
        Gitlab::ImportExport.const_defined?(version_klass_name)
      rescue => e
        Rails.logger.error("Import/Export error: #{e.message}") # rubocop:disable Gitlab/RailsLogger
        raise Gitlab::ImportExport::Error.new('Incorrect VERSION format')
      end

    end
  end
end
