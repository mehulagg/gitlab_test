# frozen_string_literal: true

module Gitlab
  module ImportExport
    module Group
      class Compressor
        include Gitlab::ImportExport::CommandLineUtil

        def self.compress(options)
          self.new(options).compress
        end

        def initialize(options)
          @archive_path  = options[:archive_path]
          @files_dir     = options[:files_dir]
          @filename_list = options[:filename_list]
        end

        def compress
          tar_czf(archive: archive_path, dir: files_dir, files: filename_list)
        end

        private

        attr_reader :archive_path, :files_dir, :filename_list
      end
    end
  end
end
