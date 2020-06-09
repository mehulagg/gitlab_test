# frozen_string_literal: true

module EE
  module API
    module Helpers
      module WikisHelpers
        extend ::Gitlab::Utils::Override
        extend ActiveSupport::Concern

        class_methods do
          def wiki_resource_kinds
            [:groups, *super]
          end
        end

        override :wiki_container
        def wiki_container(kind)
          case kind
          when :groups
            user_group
          else
            super
          end
        end
      end
    end
  end
end
