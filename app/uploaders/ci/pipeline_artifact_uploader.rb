# frozen_string_literal: true

module Ci
  class PipelineArtifactUploader < JobArtifactUploader
    def store_dir
      super
    end

    def hashed_path
      File.join(disk_hash[0..1], disk_hash[2..3], disk_hash,
        model.created_at.utc.strftime('%Y_%m_%d'), model.pipeline_id.to_s, model.id.to_s)
    end
  end
end
