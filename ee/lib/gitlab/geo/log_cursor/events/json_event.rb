# frozen_string_literal: true

module Gitlab
  module Geo
    module LogCursor
      module Events
        class JsonEvent
          attr_accessor :json

          def initialize(payload)
            @json = payload.to_h
            @logger = logger
          end

          def process
            worker_klass.perform_async(json)
          end

          private

          def workable_type
            json[:workable_type]
          end

          def workable_event
            json[:workable_event]
          end

          def worker_klass
            case workable_type
            when :git_repository
              git_repository_worker_klass
            else
              raise "Unrecognized Geo workable: #{workable_type}"
            end
          end

          def git_repository_worker_klass
            case workable_event
            when :created, :updated
              ::Geo::GitRepository::SyncWorker
            when :deleted
              ::Geo::GitRepository::DeletedWorker
            else
              raise "Unrecognized Geo Git Repository event: #{workable_event}"
            end
          end
        end
      end
    end
  end
end
