# frozen_string_literal: true

module API
  module Helpers
    module WikisHelpers
      def self.wiki_resource_kinds
        [:projects]
      end

      def wiki_container(kind)
        case kind
        when :projects
          user_project
        else
          raise "Unknown wiki container #{kind}"
        end
      end
    end
  end
end

API::Helpers::WikisHelpers.prepend_if_ee('EE::API::Helpers::WikisHelpers')
