# frozen_string_literal: true

module Gitlab
  module Ci
    module Parsers
      module Coverage
        class Cobertura
          CoberturaParserError = Class.new(Gitlab::Ci::Parsers::ParserError)

          def parse!(xml_data, coverage_report, options = {})
            root = Hash.from_xml(xml_data)

            parse_all(root, coverage_report, options)
          rescue Nokogiri::XML::SyntaxError
            raise CoberturaParserError, "XML parsing failed"
          rescue
            raise CoberturaParserError, "Cobertura parsing failed"
          end

          private

          def parse_all(root, coverage_report, options)
            return unless root.present?

            root.each do |key, value|
              parse_node(key, value, coverage_report, options)
            end
          end

          def parse_node(key, value, coverage_report, options)
            return if key == 'sources'

            if key == 'package'
              parse_package(value, coverage_report, options)
            elsif value.is_a?(Hash)
              parse_all(value, coverage_report, options)
            elsif value.is_a?(Array)
              value.each do |item|
                parse_all(item, coverage_report, options)
              end
            end
          end

          def parse_package(package, coverage_report, options)
            package_path = fetch_package_path(package, options)

            Array.wrap(package["classes"]["class"]).each do |item|
              parse_class(item, coverage_report, package_path, options)
            end
          end

          def parse_class(file, coverage_report, package_path, options)
            return unless file["filename"].present? && file["lines"].present?

            parsed_lines = parse_lines(file["lines"])

            class_path = fetch_class_path(file, package_path, options)

            coverage_report.add_file(class_path, Hash[parsed_lines])
          end

          def parse_lines(lines)
            line_array = Array.wrap(lines["line"])

            line_array.map do |line|
              # Using `Integer()` here to raise exception on invalid values
              [Integer(line["number"]), Integer(line["hits"])]
            end
          end

          def fetch_class_path(file, package_path, options)
            path = File.join(options[:src_root].to_s, package_path, file["filename"])
            path.gsub(/^\//, '') # Remove "/" if the path begins with it
          end

          def fetch_package_path(package, options)
            pattern = options[:package_path_pattern]
            replacement = options[:package_path_replacement]

            return "" if pattern.nil? || replacement.nil?

            package["name"].gsub(Regexp.new(pattern.to_s), replacement.to_s)
          end
        end
      end
    end
  end
end
