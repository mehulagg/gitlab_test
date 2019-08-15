# frozen_string_literal: true
class Packages::PackageMetadatum < ApplicationRecord
  belongs_to :package

  validates :package, presence: true

end
