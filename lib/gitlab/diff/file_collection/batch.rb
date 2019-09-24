# frozen_string_literal: true

module Gitlab
  module Diff
    module FileCollection
      class Batch < Base
        extend ::Gitlab::Utils::Override

        delegate :next_page, :current_page, :total_pages, to: :diffs

        def initialize(diffable, batch_page, batch_size, diff_options: {})
          @diffable = diffable
          @batch_page = batch_page
          @batch_size = batch_size

          super(diffable,
            project: diffable.project,
            diff_options: diff_options,
            diff_refs: diffable.diff_refs,
            fallback_diff_refs: diffable.fallback_diff_refs)
        end

        override :diffs
        def diffs
          @diffs ||=
            diffable.raw_diffs_in_batch(@batch_page, @batch_size, diff_options: diff_options)
        end

        # TODO: Move to a module
        def diff_files
          diff_files = super

          diff_files.each { |diff_file| cache.decorate(diff_file) }

          diff_files
        end

        private

        def cache
          @cache ||= Gitlab::Diff::HighlightCache.new(self)
        end
      end
    end
  end
end
