# frozen_string_literal: true

class DiffStatsEntity < Grape::Entity
  expose :added_lines
  expose :removed_lines
  expose :file_path, as: :path
  expose :new_file?, as: :new_file
  expose :deleted_file?, as: :deleted_file
end
