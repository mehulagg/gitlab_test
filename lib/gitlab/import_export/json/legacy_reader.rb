module Gitlab
  module ImportExport
    module JSON
      class LegacyReader
        include Gitlab::ImportExport::CommandLineUtil

        attr_reader :path

        def initialize(path)
          @path = path
        end

        def valid?
          File.exist?(@path)
        end

        def root_attributes(excluded_attributes = [])
          tree_hash.reject do |key, _|
            excluded_attributes.include?(key)
          end
        end

        def each_relation(key)
          value = tree_hash[key]
          return if value.nil?

          if value.is_a?(Array)
            value.each.with_index do |item, idx|
              yield(item, idx)
            end
          else
            yield(value, 0)
          end
        end

        protected

        def tree_hash
          @tree_hash ||= read_hash
        end

        def read_hash
          ActiveSupport::JSON.decode(IO.read(@path))
        end
      end
    end
  end
end
