# frozen_string_literal: true
class Packages::PackageMetadatum < ApplicationRecord
  belongs_to :package

  validates :package, presence: true

  def self.map_metadata(metadata)
    metadata.each_pair do |name, metadatum|
      if metadatum.is_a?(Hash)
        map_metadata(metadatum)
      else
        name
      end
    end
  end

end
