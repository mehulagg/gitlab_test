# frozen_string_literal: true

module Gitlab
  module ImportExport
    module Group
      module Parts
        class Saver
          include Gitlab::ImportExport::CommandLineUtil

          def self.save(part, options)
            self.new(part, options).save
          end

          def initialize(part, options)
            @part         = part
            @filenames    = options[:filenames]
            @tmp_dir_path = @part.params['tmp_dir_path']
          end

          def save
            require 'byebug'; byebug

            if compress && upload
              part.finish!
            else
              part.fail_op(error: 'Unable to compress or upload GroupExportPart')
            end
          end

          private

          attr_reader :part, :filenames, :tmp_dir_path

          def compress
            tar_czf(archive: archive_path, dir: Gitlab::ImportExport::Group.export_path(tmp_dir_path), files: filenames.join(' '))
          end

          def archive_path
            Gitlab::ImportExport::Group.export_path(File.join(tmp_dir_path, archive_filename))
          end

          def archive_filename
            @archive_filename ||= "#{Time.now.strftime('%Y-%m-%d_%H-%M-%3N')}_GroupPartExport_#{part.id}_Export_#{part.export.id}.tar.gz"
          end

          def upload
            uploader.upload(part, archive_path)
          end

          def uploader
            Gitlab::ImportExport::Group::Uploader
          end
        end
      end
    end
  end
end
