# frozen_string_literal: true

module Gitlab
  module Diff
    module FileCollection
      class Compare < Base
        def initialize(compare, repository:, diff_options:, diff_refs: nil)
          super(compare,
            repository:   repository,
            # project:      repository.project,
            diff_options: diff_options,
            diff_refs:    diff_refs)
        end

        def unfold_diff_lines(positions)
          # no-op
        end
      end
    end
  end
end
