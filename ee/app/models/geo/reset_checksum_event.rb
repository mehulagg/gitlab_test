# frozen_string_literal: true

module Geo
  class ResetChecksumEvent < ApplicationRecord
    include Geo::Model
    include Geo::Eventable

    REPOSITORY = 0
    WIKI = 1

    belongs_to :project

    validates :project, presence: true

    # It should not be limited by a repository types,
    # it can/will also reference other resources in the future
    enum resource_type: { repository: REPOSITORY, wiki: WIKI }
  end
end
