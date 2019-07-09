# frozen_string_literal: true
class Packages::PackageMetadatum < ApplicationRecord
  METADATA_SIZE = { in: 0..10.kilobytes }.freeze

  belongs_to :package
  validates :package, presence: true
  validates_size_of :metadata, METADATA_SIZE
end
