# frozen_string_literal: true

module StatusPage
  class PublishIncidentService
    include Gitlab::Utils::StrongMemoize

    def initialize(issue:)
      @project = issue.project
    end

    def execute
      return unless storage_client

      issues = find_issues

      create_list(issues.limit(20))
      create_details(issues)
    end

    private

    attr_reader :project

    def find_issues
      project
        .issues
        .preload(:notes)
        .order_created_desc
    end

    def create_list(issues)
      result = PublishListService.new(
        project: project, storage_client: storage_client, serializer: serializer)
        .execute(issues)

      if result.success?
        object_key = result.payload[:object_key]
        Gitlab::AppLogger.info("Published to #{object_key}")
      else
        Gitlab::AppLogger.error("Failed to publish issue list: #{result.message}")
      end
    end

    def create_details(issues)
      service = PublishDetailsService.new(
        project: project, storage_client: storage_client, serializer: serializer)

      issues.each do |issue|
        user_notes = issue.notes.user
        create_detail(service, issue, user_notes)
      end
    end

    def create_detail(service, issue, user_notes)
      result = service.execute(issue, user_notes)

      if result.success?
        object_key = result.payload[:object_key]
        Gitlab::AppLogger.info("Published ##{issue.iid} to #{object_key}")
      else
        Gitlab::AppLogger.error("Failed to publish ##{issue.iid}: #{result.message}")
      end
    end

    def serializer
      @serializer ||= StatusPage::IncidentSerializer.new
    end

    def storage_client
      @storage_client ||= project.status_page_setting&.s3_client
    end
  end
end
