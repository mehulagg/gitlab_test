# frozen_string_literal: true

module Gitlab
  class EncryptedConfiguration < ActiveSupport::EncryptedConfiguration
    attr_reader :key

    def initialize(config_path: nil, key: nil)
      @content_path = Pathname.new(config_path).yield_self { |path| path.symlink? ? path.realpath : path } if config_path
      @key = key
    end

    def read_env_key
      nil
    end

    def read_key_file
      nil
    end
  end
end
