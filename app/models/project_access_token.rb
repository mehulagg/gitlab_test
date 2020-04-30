# frozen_string_literal: true

class ProjectAccessToken < ApplicationRecord
  belongs_to :project
  belongs_to :personal_access_token
  has_one :user, through: :personal_access_token

  validates :project, presence: true
  validates :personal_access_token, presence: true
  validates :user, presence: true
end
