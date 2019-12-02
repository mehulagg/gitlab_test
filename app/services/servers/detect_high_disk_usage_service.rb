# frozen_string_literal: true

module Servers
  class DetectHighDiskUsageService
    attr_reader :servers

    def initialize
      @servers = ::Gitaly::Server.all
    end

    def execute
      return if servers.nil? || servers.empty?
      # return if servers.length < 2

      Rails.logger.info("Getting gitaly server disk statistics") # rubocop:disable Gitlab/RailsLogger

      for server in servers
        Rails.logger.debug("server: #{server.inspect}")
        begin
          disk_used = server.disk_used
          disk_available = server.disk_available
        rescue StandardError => e
          Rails.logger.error("Unexpected error: #{e.message}")
          raise e
        end
        Rails.logger.debug("  disk_used: #{disk_used}")
        Rails.logger.debug("  disk_available: #{disk_available}")
      end
    end
  end
end
