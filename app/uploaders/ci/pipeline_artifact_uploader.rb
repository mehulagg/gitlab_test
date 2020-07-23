# frozen_string_literal: true

module Ci
  class PipelineArtifactUploader < JobArtifactUploader
    def filename
      "#{model.file_type}-#{model.pipeline_id}"
    end

    def store_dir
      File.join(disk_hash[0..1], disk_hash[2..3], disk_hash,
        model.created_at.utc.strftime('%Y_%m_%d'), model.pipeline_id.to_s, model.id.to_s)
    end
  end
end
