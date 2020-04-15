# frozen_string_literal: true

module Geo
  class NodeStatusPostService < PostService
    include Gitlab::Geo::LogHelpers

    def execute(status)
      execute_post(primary_status_url, payload(status))
    rescue Gitlab::Geo::GeoNodeNotFoundError => e
      log_error(e.to_s)
      false
    rescue OpenSSL::Cipher::CipherError => e
      log_error('Error decrypting the Geo secret from the database. Check that the primary uses the correct db_key_base.', e)
      false
    end

    private

    def payload(status)
      status.attributes.except('id')
    end

    def primary_status_url
      primary_node.status_url
    end
  end
end
