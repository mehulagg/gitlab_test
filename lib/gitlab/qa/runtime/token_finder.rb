# frozen_string_literal: true

module Gitlab
  module QA
    module Runtime
      class TokenFinder
        def self.find_token!(token, suffix: nil)
          new(token, suffix).find_token!
        end

        attr_reader :token, :suffix

        def initialize(token, suffix)
          @token = token
          @suffix = suffix
        end

        def find_token!
          find_token_from_attrs || find_token_from_env || find_token_from_file
        end

        def find_token_from_attrs
          token
        end

        def find_token_from_env
          Env.qa_access_token
        end

        def find_token_from_file
          @token_from_file ||= File.read(token_file_path).strip
        rescue Errno::ENOENT
          fail "Please provide a valid access token with the `-t/--token` option, the `GITLAB_QA_ACCESS_TOKEN` environment variable, or in the `#{token_file_path}` file!"
        end

        private

        def token_file_path
          @token_file_path ||= File.expand_path("../api_token#{"_#{suffix}" if suffix}", __dir__)
        end
      end
    end
  end
end
