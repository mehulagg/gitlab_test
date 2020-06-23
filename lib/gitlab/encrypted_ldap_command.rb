# frozen_string_literal: true

require "rails/command/helpers/editor"

# rubocop:disable Rails/Output
module Gitlab
  class EncryptedLdapCommand
    class << self
      include Rails::Command::Helpers::Editor

      alias_method :say, :puts

      def edit
        encrypted = Gitlab::Auth::Ldap::Config.encrypted_secrets(allow_in_safe_mode: true)

        editor = ENV['EDITOR'] || 'editor'

        catch_editing_exceptions do
          encrypted.write(encrypted_file_template) unless File.exist?(encrypted.content_path)
          encrypted.change do |tmp_path|
            system("#{editor} #{tmp_path}")
          end
        end

        puts "File encrypted and saved."
      rescue ActiveSupport::MessageEncryptor::InvalidMessage
        puts "Couldn't decrypt #{encrypted.content_path}. Perhaps you passed the wrong key?"
      end

      def show
        encrypted = Gitlab::Auth::Ldap::Config.encrypted_secrets(allow_in_safe_mode: true)

        puts encrypted.read.presence || "File '#{encrypted.content_path}' does not exist. Use `rake gitlab:ldap:secret:edit` to change that."
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
