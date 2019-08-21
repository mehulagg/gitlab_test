# frozen_string_literal: true

module EE
  module API
    module Internal
      extend ActiveSupport::Concern

      prepended do
        helpers do
          extend ::Gitlab::Utils::Override
          include ActionView::Helpers::DateHelper

          override :lfs_authentication_url
          def lfs_authentication_url(project)
            project.lfs_http_url_to_repo(params[:operation])
          end

          override :add_ee_post_receive_messages
          def add_ee_post_receive_messages(messages)
            add_post_receive_alert_message(messages, geo_secondary_lag_message)
          end

          def geo_secondary_lag_message
            node = fetch_geo_node_referrer
            return unless node.present?

            lag = node.status&.db_replication_lag_seconds
            return unless lag

            lag_in_words = time_ago_in_words(lag.seconds.ago, include_seconds: true)

            "Current replication lag to \"#{node.name}\" is #{lag_in_words}."
          end

          def fetch_geo_node_referrer
            ::Gitlab::Geo::GitPushHttp.new(params[:identifier], params[:gl_repository]).fetch_referrer
          end
        end
      end
    end
  end
end
