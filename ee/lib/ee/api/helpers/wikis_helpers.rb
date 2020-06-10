# frozen_string_literal: true

module EE
  module API
    module Helpers
      module WikisHelpers
        extend ActiveSupport::Concern
        extend ::Gitlab::Utils::Override

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
