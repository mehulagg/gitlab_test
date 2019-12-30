# frozen_string_literal: true

module Gitlab
  class InvalidLogger < StandardError
    def message
      "Logger not included in MultiDestinationLogger"
    end
  end

  class MultiDestinationLogger < ::Logger
    def close
      loggers.map(&:close)
    end

    def self.debug(message)
      loggers.each { |logger| logger.build.debug(message) }
    end

    def self.error(message)
      loggers.each { |logger| logger.build.error(message) }
    end

    def self.warn(message)
      loggers.each { |logger| logger.build.warn(message) }
    end

    def self.info(message)
      loggers.each { |logger| logger.build.info(message) }
    end

    def self.primary_logger
      loggers&.first
    end

    def self.read_latest(logger = primary_logger)
      raise InvalidLogger unless loggers.include?(logger)

      logger.read_latest
    end

    def self.file_name(logger = primary_logger)
      raise InvalidLogger unless loggers.include?(logger)

      logger.file_name
    end

    def self.file_name_noext(logger = primary_logger)
      raise InvalidLogger unless loggers.include?(logger)

      logger.file_name_noext
    end

    def self.build
      raise NotImplementedError
    end

    def self.full_log_path
      raise NotImplementedError
    end

    def self.cache_key
      raise NotImplementedError
    end

    def self.loggers
      raise NotImplementedError
    end
  end
end
