# frozen_string_literal: true

module Gitlab
  module ImportExport
    class RelationTreeSaver
      include CommandLineUtil

      def serialize(exportable, relations_tree)
        if Feature.enabled?(:export_fast_serialize, default_enabled: true)
          FastHashSerializer
            .new(exportable, relations_tree)
            .execute
        else
          exportable.as_json(relations_tree)
        end
      end

      def save(tree, dir_path, filename)
        mkdir_p(dir_path)

        tree_json = JSON.generate(tree)

        File.write(File.join(dir_path, filename), tree_json)
      end
    end
  end
end
