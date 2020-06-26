# frozen_string_literal: true

module Gitlab
  module Ci
    module Build
      module Artifacts
        class Definitions
          class Base
            class << self
              attr_reader(*Definitions::AVAILABLE_ATTRIBUTES)

              def description=(value)
                unless value.is_a?(String)
                  raise ArgumentError, "The description must be a string"
                end

                @description = value
              end

              def file_type=(value)
                unless Definitions::FILE_TYPES.key?(value)
                  raise ArgumentError, "The file type #{value} must be specified in FILE_TYPES"
                end

                unless self.name.demodulize.underscore.to_sym == value
                  raise ArgumentError, "The file type #{value} must be matched with the class name"
                end

                @file_type = value
                @file_type_value = Definitions::FILE_TYPES[value]
              end

              def file_format=(value)
                unless Definitions::FILE_FORMATS.key?(value)
                  raise ArgumentError, "The file format #{value} must be specified in FILE_FORMATS"
                end

                @file_format = value
              end

              def default_file_name=(value)
                unless value.is_a?(String) || value.nil?
                  raise ArgumentError, "The default file name must be a string or nil"
                end

                @default_file_name = value
              end

              def tags=(values)
                values.each do |value|
                  unless Definitions::AVAILABLE_TAGS.include?(value)
                    raise ArgumentError, "The tag #{value} must be specified in AVAILABLE_TAGS"
                  end
                end

                @tags = values
              end

              def options=(values)
                values.each do |value|
                  unless Definitions::AVAILABLE_OPTIONS.include?(value)
                    raise ArgumentError, "The option #{value} must be specified in AVAILABLE_OPTIONS"
                  end
                end

                @options = values
              end

              def match_tags?(values)
                (values - tags).empty?
              end

              def match_options?(values)
                (values - options).empty?
              end

              Definitions::AVAILABLE_OPTIONS.each do |option|
                define_method("#{option}?") do
                  options.include?(option)
                end
              end
            end
          end
        end
      end
    end
  end
end
