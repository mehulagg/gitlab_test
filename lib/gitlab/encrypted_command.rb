# frozen_string_literal: true

require "rails/command/helpers/editor"

# rubocop:disable Rails/Output
module Gitlab
  class EncryptedCommand
    class << self
      include Rails::Command::Helpers::Editor

      alias_method :say, :puts

      def edit(file_path)
        editor = ENV['editor'] || 'editor'

        catch_editing_exceptions do
          Settings.encrypted(file_path, allow_in_safe_mode: true).write("") unless File.exist?(Rails.root.join(file_path))
          Settings.encrypted(file_path, allow_in_safe_mode: true).change do |tmp_path|
            system("#{editor} #{tmp_path}")
          end
        end

        puts "File encrypted and saved."
      rescue ActiveSupport::MessageEncryptor::InvalidMessage
        puts "Couldn't decrypt #{file_path}. Perhaps you passed the wrong key?"
      end

      def show(file_path)
        encrypted = Settings.encrypted(file_path, allow_in_safe_mode: true)

        puts encrypted.read.presence || "File '#{file_path}' does not exist. Use `rake gitlab:encrypted:edit #{file_path}` to change that."
      end
    end
  end
end
# rubocop:enable Rails/Output
