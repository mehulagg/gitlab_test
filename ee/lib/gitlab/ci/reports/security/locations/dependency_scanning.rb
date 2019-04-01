# frozen_string_literal: true

module Gitlab
  module Ci
    module Reports
      module Security
        module Locations
          class DependencyScanning < Base
            attr_reader :file_path
            attr_reader :package_name
            attr_reader :package_version

            def initialize(file_path:, package_name:, package_version: nil)
              @file_path = file_path
              @package_name = package_name
              @package_version = package_version

              @fingerprint = generate_fingerprint
            end

            private

            def generate_fingerprint
              Digest::SHA1.hexdigest("#{file_path}:#{package_name}")
            end
          end
        end
      end
    end
  end
end
