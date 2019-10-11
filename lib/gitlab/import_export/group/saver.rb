# frozen_string_literal: true

module Gitlab
  module ImportExport
    module Group
      class Saver
        def self.save(exportable, options)
          self.new(exportable, options).save
        end

        def initialize(exportable, options)
          @exportable    = exportable
          @filename_list = options[:filename_list].join(' ')
          @tmp_dir_path  = options[:tmp_dir_path]
        end

        def save
          if compress_files && upload_archive
            clean_up

            exportable.finish!
          else
            exportable.fail_op!(error: "Unable to compress or upload #{exportable_class_name}")
          end
        rescue => e
          exportable.fail_op!(error: e.message)
        end

        private

        attr_reader :exportable, :filename_list, :tmp_dir_path

        def compress_files
          Gitlab::ImportExport::Group::Compressor.compress(
            archive_path:  archive_path,
            files_dir:     absolute_dir_path,
            filename_list: filename_list
          )
        end

        def upload_archive
          Gitlab::ImportExport::Group::Uploader.upload(exportable, archive_path)
        end

        def archive_path
          File.join(absolute_dir_path, archive_filename)
        end

        def clean_up
          FileUtils.rm_rf(absolute_dir_path)
        end

        def archive_filename
          @archive_filename ||= "#{Time.now.strftime('%Y-%m-%d_%H-%M-%3N')}_#{exportable_class_name}_#{exportable.id}.tar.gz"
        end

        def absolute_dir_path
          Gitlab::ImportExport::Group.export_path(tmp_dir_path)
        end

        def exportable_class_name
          exportable.class.name
        end
      end
    end
  end
end
