# frozen_string_literal: true

class Packages::ConanFileMetadatum < ApplicationRecord
  belongs_to :package_file

  validates :package_file, presence: true
  validates :path, presence: true
  validates :revision, presence: true

  def package_path?
    path.include?('/package')
  end

  def recipe_path?
    path.include?('/export')
  end
end
