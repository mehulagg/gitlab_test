# frozen_string_literal: true

module Gitlab
  module ImportExport
    module Group
      module Exporters
        class Base
          include Gitlab::ImportExport::CommandLineUtil

          def initialize(part)
            @part         = part
            @name         = part.name
            @params       = part.params
            @group_id     = @params[:group_id]
            @user_id      = @params[:group_id]
            @tmp_dir_path = @params[:tmp_dir_path]
          end

          def export
            mkdir_p(export_path) unless File.directory?(export_path)

            filename_list = export_part

            part.upload!(filename_list: filename_list, tmp_dir_path: tmp_dir_path)
          rescue => e
            part.fail_op!(error: e.message)
          end

          # Implement in sub class
          def export_part
            nil
          end

          private

          attr_reader :part, :tmp_dir_path, :group_id, :user_id, :params, :name

          def group
            @group ||= ::Group.find(group_id)
          end

          def export_path
            Gitlab::ImportExport::Group.export_path(tmp_dir_path)
          end

          def filepath(filename)
            File.join(export_path, filename)
          end
        end
      end
    end
  end
end
