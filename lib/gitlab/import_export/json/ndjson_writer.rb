module Gitlab
  module ImportExport
    module JSON
      class NdjsonWriter
        include Gitlab::ImportExport::CommandLineUtil

        attr_reader :dir_path

        def initialize(dir_path, root)
          @dir_path = dir_path
          @root = root
          @files = {}

          mkdir_p(dir_path)
        end

        def close
          @files.values.each(&:close)
          @files.clear
        end

        def set(hash)
          append(@root, hash)
        end

        def write(key, value)
          append(key, value)
        end

        def append(key, value)
          h = file(key)
          h.write(value.to_json)
          h.write("\n")
        end

        private

        def file(key)
          @files[key] ||= File.open(file_path(key), "wb")
        end

        def file_path(key)
          File.join(@dir_path, "#{key}.ndjson")
        end
      end
    end
  end
end
