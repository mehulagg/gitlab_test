# frozen_string_literal: true
class Packages::PackageMetadatum < ApplicationRecord
  belongs_to :package

  validates :package, presence: true
  validates_size_of :metadata, { in: 0..10.kilobytes }

end
