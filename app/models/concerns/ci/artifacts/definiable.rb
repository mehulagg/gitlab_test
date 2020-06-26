# frozen_string_literal: true

module Ci
  module Artifacts
    module Definiable
      extend ActiveSupport::Concern

      included do
        enum file_type: ::Gitlab::Ci::Build::Artifacts::Definitions::FILE_TYPES
        enum file_format: ::Gitlab::Ci::Build::Artifacts::Definitions::FILE_FORMATS, _suffix: true

        scope :with_file_types, -> (file_types) do
          types = self.file_types.select { |file_type| file_types.include?(file_type) }.values

          where(file_type: types)
        end

        scope :with_defined_tags, -> (*tags) do
          types = ::Gitlab::Ci::Build::Artifacts::Definitions
            .find_by_tags(*tags).map(&:file_type_value)

          where(file_type: types)
        end

        scope :with_defined_options, -> (*options) do
          types = ::Gitlab::Ci::Build::Artifacts::Definitions
            .find_by_options(*options).map(&:file_type_value)

          where(file_type: types)
        end
      end
    end
  end
end
