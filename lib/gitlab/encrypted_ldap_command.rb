# frozen_string_literal: true

require "rails/command/helpers/editor"

# rubocop:disable Rails/Output
module Gitlab
  class EncryptedLdapCommand
    class << self
      include Rails::Command::Helpers::Editor

      alias_method :say, :puts

      def edit
        file_path = Gitlab.config.ldap.secret_file

        editor = ENV['EDITOR'] || 'editor'

        catch_editing_exceptions do
          Settings.encrypted(file_path, allow_in_safe_mode: true).write(encrypted_file_template) unless File.exist?(file_path)
          Settings.encrypted(file_path, allow_in_safe_mode: true).change do |tmp_path|
            system("#{editor} #{tmp_path}")
          end
        end

        puts "File encrypted and saved."
      rescue ActiveSupport::MessageEncryptor::InvalidMessage
        puts "Couldn't decrypt #{file_path}. Perhaps you passed the wrong key?"
      end

      def show
        encrypted = Settings.encrypted(Gitlab.config.ldap.secret_file, allow_in_safe_mode: true)

        puts encrypted.read.presence || "File '#{Gitlab.config.ldap.secret_file}' does not exist. Use `rake gitlab:ldap:secret:edit` to change that."
      end

      private

      def encrypted_file_template
        <<~YAML
          # main:
          #   password: '123'
        YAML
      end
    end
  end
end
# rubocop:enable Rails/Output
