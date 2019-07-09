# frozen_string_literal: true
class Packages::PackageTag < ApplicationRecord
  belongs_to :package

  validates :package, presence: true

  scope :with_name, -> (name) { where(name: name) }
  scope :with_name_and_id, ->(name, id) { with_name(name).where(package_id: id) }

  def self.with_package_name(package_name)
    joins(:package).where(packages_packages: { name: package_name })
  end

  def self.with_tag_name_and_package_name(tag_name, package_name)
    with_name(tag_name).with_package_name(package_name)
  end

  def self.build_tags_hash_for(package_name)
    with_package_name(package_name).inject({}) do |hash, tag|
      hash.merge(tag.name => tag.package.version)
    end
  end
end
