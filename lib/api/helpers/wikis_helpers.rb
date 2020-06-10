# frozen_string_literal: true

module API
  module Helpers
    module WikisHelpers
      def wiki_container(kind)
        case kind
        when :projects
          user_project
        else
          raise "Unknown wiki container #{kind}"
        end
      end

      def self.helpers(kind)
        Module.new do
          include WikisHelpers

          define_method :container do
            wiki_container(kind)
          end

          define_method :wiki_page do
            container = wiki_container(kind)
            page = Wiki.for_container(container, current_user).find_page(params[:slug])

            page || not_found!('Wiki Page')
          end
        end
      end
    end
  end
end

API::Helpers::WikisHelpers.prepend_if_ee('EE::API::Helpers::WikisHelpers')
