# frozen_string_literal: true
class Packages::PackageMetadatum < ApplicationRecord
  belongs_to :package

  validates :package, presence: true
  validates_size_of :metadata, { in: 0..10.kilobytes }

  def self.map_metadata(metadata)
    metadata.each_pair do |k, v|
      if v.is_a?(Hash)
        map_metadata(v)
      else
        v
      end
    end
  end

end
