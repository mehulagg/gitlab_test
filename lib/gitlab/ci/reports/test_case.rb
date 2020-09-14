# frozen_string_literal: true

module Gitlab
  module Ci
    module Reports
      class TestCase
        STATUS_SUCCESS = 'success'
        STATUS_FAILED = 'failed'
        STATUS_SKIPPED = 'skipped'
        STATUS_ERROR = 'error'
        STATUS_TYPES = [STATUS_ERROR, STATUS_FAILED, STATUS_SUCCESS, STATUS_SKIPPED].freeze

        attr_reader :name, :classname, :execution_time, :status, :file, :system_output, :stack_trace, :key, :attachment, :job

        def initialize(params)
          @name = params.fetch(:name)
          @classname = params.fetch(:classname)
          @file = params.fetch(:file, nil)
          @execution_time = params.fetch(:execution_time).to_f
          @status = params.fetch(:status)
          @system_output = params.fetch(:system_output, nil)
          @stack_trace = params.fetch(:stack_trace, nil)
          @attachment = params.fetch(:attachment, nil)
          @job = params.fetch(:job, nil)

          @key = sanitize_key_name("#{classname}_#{name}")
        end

        def has_attachment?
          attachment.present?
        end

        def attachment_url
          return unless has_attachment?

          Rails.application.routes.url_helpers.file_project_job_artifacts_path(
            job.project,
            job.id,
            attachment
          )
        end

        private

        def sanitize_key_name(key)
          key.gsub(/[^0-9A-Za-z]/, '-')
        end
      end
    end
  end
end
