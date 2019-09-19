# frozen_string_literal: true

module Gitlab
  module ImportExport
    module Group
      module Parts
        class Base
          def initialize(group_part, export, params)
            @group_part = group_part
            @export     = export
            @params     = params
          end

          private

          attr_reader :group_part, :export, :params
        end
      end
    end
  end
end
