# frozen_string_literal: true

module Gitlab
  module ImportExport
    module V0_2_4 # rubocop:disable Naming/ClassAndModuleCamelCase
      class Config < Gitlab::ImportExport::Config
        class << self
          def config_file
            Rails.root.join('lib/gitlab/import_export/V0_2_4/import_export.yml')
          end

          def group_config_file
            Rails.root.join('lib/gitlab/import_export/V0_2_4/group_import_export.yml')
          end
        end

        def initialize(config: Config.config_file)
          super
        end
      end
    end
  end
end
