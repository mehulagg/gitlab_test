# frozen_string_literal: true

module Gitlab
  module Geo
    module Replicable
      module Registry
        extend ActiveSupport::Concern

        # To be called by a backfill worker. Creates missing registries.
        # A separate worker will query for registries that are not synced, and
        # will sync them. See https://gitlab.com/gitlab-org/gitlab/issues/34269
        def backfill_registries(*args)
          raise NotImplementedError
        end
      end
    end
  end
end
