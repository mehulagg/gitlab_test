# frozen_string_literal: true

module Gitlab
  module ImportExport
    module Group
      class ExportService < BaseService
        def initialize(group_id, user_id)
          @group_id = group_id
          @user_id = user_id
        end

        def execute
          export.start!
        end

        private

        def export
          @export ||= export_creator.create
        end

        def export_creator
          @export_creator ||= Gitlab::ImportExport::Group::ExportCreator.new(@group_id, @user_id)
        end
      end
    end
  end
end
