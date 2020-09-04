# frozen_string_literal: true

class Lab < ApplicationRecord
  # Every real Group gets a hidden Project
  belongs_to :group

  # Every real Project gets an intermediate Group
  belongs_to :project

  validates :group, uniqueness: {scope: :project}
end
