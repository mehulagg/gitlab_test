# frozen_string_literal: true

module Servers
  class DetectHighDiskUsageService
    attr_reader :servers

    DISK_USAGE_PERCENTAGE_THRESHOLD = 65

    def initialize
      @servers = ::Gitaly::Server.all
    end

    def execute
      return if servers.nil? || servers.empty?
      return if servers.length < 2

      select_servers_with_high_disk_usage_percentage
    end

    protected

    def select_servers_with_high_disk_usage_percentage(threshold=DISK_USAGE_PERCENTAGE_THRESHOLD)
      servers.select { |server|
        disk_usage_percentage(server) > threshold
      }
    end

    private

    def disk_usage_percentage(server)
      Rails.logger.info("Getting disk usage percentage for gitaly server: #{server.address}")  # rubocop:disable Gitlab/RailsLogger

      disk_usage_percentage = 0
      disk_used = 0
      disk_available = 0
      begin
        disk_used = server.disk_used
        disk_available = server.disk_available
      rescue StandardError => e
        Gitlab::ErrorTracking.track_exception(ex)
        Rails.logger.warn("Unexpected error getting disk usage percentage: #{e.message}")  # rubocop:disable Gitlab/RailsLogger
      end

      if disk_available > 0
        disk_usage_percentage = (disk_used / disk_available.to_f) * 100
      end

      disk_usage_percentage
    end
  end
end
