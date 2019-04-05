# frozen_string_literal: true

module Gitlab
  module Ci
    module Parsers
      module Security
        class Dast < Common
          FORMAT_VERSION = '2.0'.freeze

          protected

          def parse_report(json_data)
            report = super

            format_report(report)
          end

          private

          def format_report(data)
            {
              'vulnerabilities' => extract_vulnerabilities_from(data),
              'version' => FORMAT_VERSION
            }
          end

          def extract_vulnerabilities_from(data)
            site = data['site']
            results = []

            if site
              host = site['@name']

              site['alerts'].each do |vulnerability|
                results += flatten_vulnerabilities(vulnerability, host)
              end
            end

            results
          end

          def flatten_vulnerabilities(vulnerability, host)
            vulnerability['instances'].map do |instance|
              Formatters::Dast.new(vulnerability).format(instance, host)
            end
          end

          def generate_location_fingerprint(location)
            Digest::SHA1.hexdigest("#{location['path']}:#{location['method']}:#{location['param']}")
          end
        end
      end
    end
  end
end
