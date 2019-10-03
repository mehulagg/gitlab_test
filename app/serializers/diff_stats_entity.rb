# frozen_string_literal: true

class DiffStatsEntity < Grape::Entity
  expose :additions, as: :added_lines
  expose :deletions, as: :removed_lines
  expose :path
end
