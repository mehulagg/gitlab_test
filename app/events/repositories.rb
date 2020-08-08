# frozen_string_literal: true

module Repositories
  BranchDeletedEvent = Class.new(Gitlab::EventStore::Event)
  TagDeletedEvent = Class.new(Gitlab::EventStore::Event)
end
