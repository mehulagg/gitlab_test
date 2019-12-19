# frozen_string_literal: true

module Geo
  class RepositoryMovedEvent < ApplicationRecord
    include Geo::Model
    include Geo::Eventable

    belongs_to :project

    validates :project, :old_repository_storage, :new_repository_storage, presence: true
  end
end
