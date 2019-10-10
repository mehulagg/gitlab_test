# frozen_string_literal: true

module Gitlab
  module ImportExport
    module Group
      class Saver
        include Gitlab::ImportExport::CommandLineUtil

        def self.save(exportable, options)
          self.new(exportable, options).save
        end

        def initialize(exportable, options)
          @exportable = exportable
          @filenames = options['filenames']
        end

        private

        attr_reader :exportable, :filenames

        def save
          archive = compress_files

          upload(archive) if archive
        end

        def compress_files


        end

        def upload(archive)
          uploader.upload(archive)
        end

        def uploader
          @uploader ||= Gitlab::ImportExport::Group::Uploader.new
        end
      end
    end
  end
end
