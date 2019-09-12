# frozen_string_literal: true

module Clusters
  module Applications
    class DestroyService < ::Clusters::Applications::BaseService
      ApplicationCantBeUninstalled = Class.new(StandardError)

      def execute(_request)
        instantiate_application.tap do |application|
          raise ApplicationCantBeUninstalled unless application.can_uninstall?

          application.make_scheduled!

          Clusters::Applications::UninstallWorker.perform_async(application.name, application.id)
        end
      end

      private

      def builder
        cluster.public_send(:"application_#{application_name}") # rubocop:disable GitlabSecurity/PublicSend
      end
    end
  end
end
