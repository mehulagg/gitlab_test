# frozen_string_literal: true

module Gitlab
  module Geo
    module Replicable
      module Model
        extend ActiveSupport::Concern

        def replicable_create
          return if skip_replicable_events?

          strategy::Events::CreateEvent.create_for(self)
        end

        def replicable_update
          return if skip_replicable_events?

          strategy::Events::UpdateEvent.create_for(self)
        end

        def replicable_move
          return if skip_replicable_events?

          # TODO
          # strategy::Events::MoveEvent.create_for(self)
        end

        def replicable_delete
          return if skip_replicable_events?

          # TODO
          # strategy::Events::DeleteEvent.create_for(self)
        end

        def skip_replicable_events?
          Gitlab::Geo.secondary?
        end

        def registry
          raise NotImplementedError
        end

        def replicable_registry_class
          raise NotImplementedError
        end
      end
    end
  end
end
