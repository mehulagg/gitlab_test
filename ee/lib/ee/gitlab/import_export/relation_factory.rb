# frozen_string_literal: true

module EE
  module Gitlab
    module ImportExport
      module RelationFactory
        extend ActiveSupport::Concern

        EE_EXISTING_OBJECT_CHECK = %w[DesignManagement::Design].freeze

        class_methods do
          extend ::Gitlab::Utils::Override

          override :existing_object_check
          def existing_object_check
            super + EE_EXISTING_OBJECT_CHECK
          end
        end
      end
    end
  end
end
