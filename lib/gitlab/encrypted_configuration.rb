# frozen_string_literal: true

module Gitlab
  class EncryptedConfiguration < ActiveSupport::EncryptedConfiguration
    def initialize(config_path: nil, key: nil, key_path: nil, env_key: nil, raise_if_missing_key: false)
      @content_path = Pathname.new(config_path).yield_self { |path| path.symlink? ? path.realpath : path } if config_path
      @key_path = Pathname.new(key_path) if key_path
      @key, @env_key, @raise_if_missing_key = key, env_key, raise_if_missing_key
    end

    def key
      @key || super
    end

    def read_env_key
      super if env_key
    end

    def read_key_file
      super if key_path
    end
  end
end
