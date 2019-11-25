# frozen_string_literal: true

# The including class should include ::Gitlab::Geo::Replicable::Model first
module Gitlab
  module Geo
    module Replicable
      module Strategies
        module Repository
          module Model
            extend ActiveSupport::Concern

            included do
            end

            def strategy
              ::Gitlab::Geo::Replicable::Strategies::Repository
            end

            def skip_replicable_events?
              return true if repo_type.project? || repo_type.wiki? # until we migrate these to the new way

              super
            end
          end
        end
      end
    end
  end
end
