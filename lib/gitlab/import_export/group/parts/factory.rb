# frozen_string_literal: true

module Gitlab
  module ImportExport
    module Group
      module Parts
        class Factory
          def self.parts_for(group_part, export, params)
            self.parts_klass(group_part).new(group_part, export, params)
          end

          def self.parts_klass(group_part)
            case group_part
            when :relations
              Relations
            when :projects
              Projects
            when :activity
              Activity
            when :packages
              Packages
            when :attributes
              Attributes
            else
              raise NotImplementedError
            end
          end
        end
      end
    end
  end
end
