module Geo
  class ReplicationTogglePostService < PostService
    def execute(node)
      execute_post(node.toggle_replication_url, {})
    rescue Gitlab::Geo::GeoNodeNotFoundError => e
      log_error(e.to_s)
      false
    rescue OpenSSL::Cipher::CipherError => e
      log_error('Error decrypting the Geo secret from the database. Check that the primary uses the correct db_key_base.', e)
      false
    end
  end
end
