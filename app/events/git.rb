# frozen_string_literal: true

module Git
  BranchPushedEvent = Class.new(Gitlab::EventStore::Event)
  TagPushedEvent = Class.new(Gitlab::EventStore::Event)
end
