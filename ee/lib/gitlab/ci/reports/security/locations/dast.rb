# frozen_string_literal: true

module Gitlab
  module Ci
    module Reports
      module Security
        module Locations
          class Dast < Base
            attr_reader :hostname
            attr_reader :method_name
            attr_reader :param
            attr_reader :path

            def initialize(hostname:, method_name:, path:, param: nil)
              @hostname = hostname
              @method_name = method_name
              @param = param
              @path = path
            end

            private

            def fingerprint_data
              "#{normalize_path}:#{method_name}:#{param}"
            end

            def normalize_path
              # remove query string, fragment and end slash
              URI(path).path.gsub(/\/$/, '')
            rescue URI::InvalidURIError
              return path
            end
          end
        end
      end
    end
  end
end
