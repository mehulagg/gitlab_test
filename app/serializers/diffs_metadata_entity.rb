# frozen_string_literal: true

class DiffsMetadataEntity < DiffsEntity
  unexpose :diff_files
  expose :diff_stats, using: DiffStatsEntity do |diffs|
    # This method returns a enumerable (Gitlab::Git::DiffStatsCollection)
    # therefore a conversion is required.
    diffs.diff_stats.to_a
  end
end
