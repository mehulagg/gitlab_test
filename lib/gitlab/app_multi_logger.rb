# frozen_string_literal: true

module Gitlab
  class AppTextLogger < Gitlab::Logger
    def self.file_name_noext
      'application'
    end

    def format_message(severity, timestamp, progname, msg)
      "#{timestamp.to_s(:long)}: #{msg}\n"
    end
  end

  class AppJsonLogger < Gitlab::JsonLogger
    def self.file_name_noext
      'application_json'
    end
  end

  class AppMultiLogger < Gitlab::MultiDestinationLogger
    def self.loggers
      @loggers ||= [
        Gitlab::AppTextLogger,
        Gitlab::AppJsonLogger
      ]
    end

    def self.primary_logger
      Gitlab::AppTextLogger
    end
  end
end
