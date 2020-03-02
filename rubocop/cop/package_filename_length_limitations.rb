# frozen_string_literal: true
require "rubygems/package"

module RuboCop
  module Cop
    class PackageFilenameLengthLimitations < Cop
      include RangeHelp

      def investigate(processed_source)
        file_path = processed_source.file_path
        check_file_path(file_path) unless config.file_to_exclude?(file_path)
      end

      private

      def check_file_path(file_path)
        Gem::Package::TarWriter.new(nil).split_name(file_path)
      rescue Gem::Package::Error => error
        add_offense(nil, location:  overflowed_buffer(file_path), message: error.message)
      end

      def override_buffer_with_name(old_buffer, filename)
        Parser::Source::Buffer.new(old_buffer.name, old_buffer.first_line).tap do |new_buffer|
          new_buffer.source = filename
        end
      end

      def overflowed_buffer(filename)
        source_range(override_buffer_with_name(processed_source.buffer, filename), 1, 0, filename.length)
      end
    end
  end
end
