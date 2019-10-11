# frozen_string_literal: true

module Gitlab
  module ImportExport
    module Group
      class ExportCreator
        def initialize(group_id, user_id)
          @group_id = group_id
          @user_id  = user_id
        end

        def create
          export = build_export
          build_export_parts(export)

          export.save!
          export
        end

        private

        attr_reader :export

        def build_export
          @export ||= group.exports.new
        end

        def build_export_parts(export)
          group_parts.each do |group_part|
            Parts::Factory.parts_for(group_part, export, params).export_parts
          end
        end

        def group
          @group ||= ::Group.find(@group_id)
        end

        def user
          @user ||= ::User.find(@user_id)
        end

        def group_parts
          config[:include]
        end

        def config
          @config ||= Gitlab::ImportExport::Config.new(config: Gitlab::ImportExport::Group.config_file).to_h
        end

        def relative_export_path
          Gitlab::ImportExport::Group.relative_path(group)
        end

        def params
          {
            group_id:     group.id,
            user_id:      user.id,
            config:       config,
            tmp_dir_path: relative_export_path
          }
        end
      end
    end
  end
end
