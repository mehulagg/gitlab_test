# frozen_string_literal: true

module Analytics
  module CodeAnalytics
    class HotspotsTree
      attr_reader :file_edits_mapping

      def initialize(file_edits_mapping: {})
        @file_edits_mapping = file_edits_mapping
      end

      def build
        tree = []

        file_edits_mapping.each do |file_path, num_edits|
          directory = directory_path(file_path)
          node = {
            entity: directory,
            num_edits: 0,
            children: []
          }

          list_edited_files(directory).each do |entity|
            node[:children].push({
              entity: entity,
              num_edits: file_edits_mapping[entity]
            })

            node[:num_edits] += file_edits_mapping[entity]
            file_edits_mapping.delete(entity)
          end

          tree.push node
        end

        tree
      end

      private

      def list_edited_files(directory)
        file_edits_mapping.keys
          .select { |key| key =~ /^#{Regexp.quote(directory)}/ }
      end

      def directory_path(file_path)
        File.dirname(file_path) + '/'
      end
    end
  end
end
