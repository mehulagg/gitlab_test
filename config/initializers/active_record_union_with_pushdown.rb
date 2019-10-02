# frozen_string_literal: true

module ActiveRecord
  class Relation
    include Gitlab::Database::ActiveRecordUnion
  end
end
