# frozen_string_literal: true

module Gitlab
  module ImportExport
    module Group
      class Uploader
        def self.upload(exportable, file_path)
          self.new(exportable, file_path).upload
        end

        def initialize(exportable, file_path)
          @exportable = exportable
          @file_path  = file_path
        end

        def upload
          File.open(file_path) { |file| exportable.export_file = file }

          exportable.save!
        end

        private

        attr_reader :exportable, :file_path
      end
    end
  end
end
