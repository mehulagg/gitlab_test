# frozen_string_literal: true

module Gitlab
  module ImportExport
    module V0_2_4 # rubocop:disable Naming/ClassAndModuleCamelCase
      class ProjectTreeSaver < Gitlab::ImportExport::ProjectTreeSaver
        extend ::Gitlab::Utils::Override
        # Aware that the resulting hash needs to be pure-hash and
        # does not include any AR objects anymore, only objects that run `.to_json`
        override :fix_project_tree
        def fix_project_tree(project_tree)
          super

          RelationRenameService.add_new_associations(project_tree)
        end
      end
    end
  end
end
