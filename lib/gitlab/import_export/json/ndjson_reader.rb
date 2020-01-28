module Gitlab
  module ImportExport
    module JSON
      class NdjsonReader
        include Gitlab::ImportExport::CommandLineUtil

        attr_reader :dir_path, :root

        def initialize(dir_path, root)
          @dir_path = dir_path
          @root = root
        end

        def valid?
          puts "Testing: #{file_path(root)}"
          File.exist?(file_path(root))
        end

        def root_attributes(excluded_attributes = [])
          each_relation(root) do |hash|
            return hash.reject do |key, _|
              excluded_attributes.include?(key)
            end
          end

          nil
        end

        def each_relation(key)
          path = File.join(@dir_path, "#{key}.ndjson")
          return unless File.exist?(file_path(key))

          File.foreach(file_path(key)).with_index do |line, line_num|
            json = ActiveSupport::JSON.decode(line)
            yield(json, line_num)
          end
        end

        private

        def file_path(key)
          File.join(@dir_path, "#{key}.ndjson")
        end
      end
    end
  end
end
