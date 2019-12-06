# frozen_string_literal: true

require 'ruby-prof'
require 'memory_profiler'

module Gitlab
  module SidekiqMiddleware
    class Profiler
      attr_accessor :profile_option

      def call(worker, job, queue)
        if profile?(worker, job)
          call_with_profiling { yield }
        else
          yield
        end
      end

      private

      def profile?(worker, job)
        Rails.logger.error("qingyudebug: entering profile? method. Worker: #{worker}, job: #{job}")

        profile_option_str = ::Gitlab::Redis::SharedState.with do |redis|
          redis.get(sidekiq_profile_key_for(job.id))
        end

        profile_option = JSON.parse(profile_option_str)

        Rails.logger.error("qingyudebug: profile_option: #{profile_option}")

        profile_option
      rescue JSON::ParserError =>  e
        Rails.logger.error("qingyudebug: JSON parse failed: #{e.message}")
      end

      def call_with_profiling
        Rails.logger.error("qingyudebug: enter call_with_profiling: #{profile_option}")
        return yield unless profile_option && profile_option[:mode] && profile_option[:worker]

        case profile_option['mode']
        when 'sidekiq_execution'
          call_with_call_stack_profiling { yield }
        when 'sidekiq_memory'
          call_with_memory_profiling { yield }
        else
          Rails.logger.error("qingyudebug: invalid profile option: #{profile_option}")

          yield
        end
      end

      def call_with_call_stack_profiling
        raise "call_with_call_stack_profiling not implemented!"
      end

      def call_with_memory_profiling
        ret = nil
        report = MemoryProfiler.report do
          ret = catch(:warden) do
            yield
          end
        end

        generate_report('memory', 'txt') do |file|
          report.pretty_print(to_file: file)
        end

        handle_request_ret(ret)
      end

      def generate_report(report_type, extension)
        file_name = "#{env['PATH_INFO'].tr('/', '|')}_#{Time.current.to_i}"\
                    "_#{report_type}.#{extension}"
        file_path = "#{PROFILES_DIR}/#{file_name}"

        FileUtils.mkdir_p(PROFILES_DIR)

        begin
          File.open(file_path, 'wb') do |file|
            yield(file)
          end
        rescue
          FileUtils.rm(file_path)
        end
      end

      def report_path(report_type, extension)
        file_name = "#{env['PATH_INFO'].tr('/', '|')}_#{Time.current.to_i}"\
                    "_#{report_type}.#{extension}"
        file_path = "#{PROFILES_DIR}/#{file_name}"
      end

      SIDEKIQ_PROFILE_KEY = 'sidekiq-profile:%s'
      def sidekiq_profile_key_for(jid)
        SIDEKIQ_PROFILE_KEY % jid
      end
    end
  end
end
