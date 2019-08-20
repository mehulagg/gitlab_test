# frozen_string_literal: true

module Gitlab
  module Geo
    class GitPushHttp
      def initialize(gl_id, gl_repository)
        @gl_id = gl_id
        @gl_repository = gl_repository
      end

      def cache_referrer(geo_node_referrer_id)
        return unless geo_node_referrer_id.present?

        Rails.cache.write(cache_key, geo_node_referrer_id, expires_in: 5.minutes)
      end

      def fetch_referrer
        id = Rails.cache.read(cache_key)

        if id
          # There is a race condition but since this is only used to display a
          # notice, it's ok. If we didn't delete it, then a subsequent push
          # directly to the primary would inappropriately show the secondary lag
          # notice again.
          Rails.cache.delete(cache_key)

          GeoNode.find_by_id(id)
        end
      end

      private

      def cache_key
        [
          'git_receive_pack',
          'geo_node_referrer_id',
          @gl_id,
          @gl_repository
        ].join(':')
      end
    end
  end
end
