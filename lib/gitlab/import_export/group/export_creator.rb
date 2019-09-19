# frozen_string_literal: true

module Gitlab
  module ImportExport
    module Group
      class ExportCreator
        def initialize(group_id, user_id)
          @group_id = group_id
          @user_id = user_id
        end

        def create
          GroupExport.transaction do
            create_export
            create_export_parts
            export.save!
            export
          end
        end

        private

        attr_reader :export

        def create_export
          @export ||= group.exports.new
        end

        def create_export_parts
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
          @export_path ||= Gitlab::ImportExport::Group.relative_path(group)
        end

        def params
          {
            group_id: group.id,
            user_id: user.id,
            tmp_dir_path: relative_export_path,
            config: config
          }
        end
      end
    end
  end
end

