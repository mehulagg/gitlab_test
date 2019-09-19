# frozen_string_literal: true

module Gitlab
  module ImportExport
    module Group
      extend self

      FILENAME_LIMIT = 50

      def export_path(relative_path)
        File.join(storage_path, relative_path)
      end

      def storage_path
        File.join(::Settings.shared['path'], 'tmp/group_exports')
      end

      def group_filename
        'group.json'
      end

      def relation_filename(relation_name)
        "#{relation_name}.json"
      end

      def config_file
        Rails.root.join('lib/gitlab/import_export/group/import_export.yml')
      end

      def relative_path(group)
        @relative_path ||= File.join(group.full_path, SecureRandom.hex)
      end

      def export_filename(group:)
        basename = "#{Time.now.strftime('%Y-%m-%d_%H-%M-%3N')}_#{group.full_path.tr('/', '_')}"

        "#{basename[0..FILENAME_LIMIT]}_export.tar.gz"
      end

      def reset_tokens?
        true
      end
    end
  end
end
