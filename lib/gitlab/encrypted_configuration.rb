# frozen_string_literal: true

module Gitlab
  class EncryptedConfiguration
    delegate :[], :fetch, to: :config
    delegate_missing_to :options
    attr_reader :content_path, :key, :previous_keys

    CIPHER = "aes-128-gcm"

    def initialize(content_path: nil, key: nil, previous_keys: [])
      @content_path = Pathname.new(content_path).yield_self { |path| path.symlink? ? path.realpath : path } if content_path
      @key = key
      @previous_keys = previous_keys
    end

    def read
      if !key.nil? && content_path.exist?
        decrypt content_path.binread
      else
        ""
      end
    end

    def write(contents)
      # ensure contents are valid to deserialize before write
      deserialize(contents)

      IO.binwrite "#{content_path}.tmp", encrypt(contents)
      FileUtils.mv "#{content_path}.tmp", content_path
    end

    def config
      @config ||= deserialize(read).deep_symbolize_keys
    end

    def change(&block)
      writing read, &block
    end

    private
    def writing(contents)
      tmp_file = "#{Process.pid}.#{content_path.basename.to_s.chomp('.enc')}"
      tmp_path = Pathname.new File.join(Dir.tmpdir, tmp_file)
      tmp_path.binwrite contents

      yield tmp_path

      updated_contents = tmp_path.binread

      write(updated_contents) if updated_contents != contents
    ensure
      FileUtils.rm(tmp_path) if tmp_path&.exist?
    end

    def encrypt(contents)
      encryptor.encrypt_and_sign contents
    end

    def decrypt(contents)
      encryptor.decrypt_and_verify contents
    end

    def encryptor
      return @encryptor if @encryptor

      @encryptor = ActiveSupport::MessageEncryptor.new([ key ].pack("H*"), cipher: CIPHER)

      # Allow fallback to previous keys
      for key in @previous_keys
        @encryptor.rotate([ key ].pack("H*"))
      end

      @encryptor
    end

    def options
      # Allows top level keys to be referenced using dot syntax
      @options ||= ActiveSupport::InheritableOptions.new(config)
    end

    def deserialize(contents)
      YAML.load(contents).presence || {}
    end
  end
end
