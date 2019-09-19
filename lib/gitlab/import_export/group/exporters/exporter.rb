# frozen_string_literal: true

module Gitlab
  module ImportExport
    module Group
      module Exporters
        class Exporter
          def self.for(part)
            self.exporter_klass(part.name).new(part)
          end

          def self.exporter_klass(part_name)
            case part_name.to_sym
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
