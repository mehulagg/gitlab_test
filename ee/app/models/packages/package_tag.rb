# frozen_string_literal: true
class Packages::PackageTag < ApplicationRecord
  belongs_to :package

  validates :package, presence: true

  scope :with_name_and_id, ->(name, id) { where(name: name, package_id: id) }
  scope :with_tag_and_package_name, ->(tag, name) {where(name: tag)}

  def self.find_tags_by_package(package_name)
    joins(:package).where(packages_packages: { name: package_name })
  end

  def self.find_packages_by_package_tag(tag_name, package_name)
    where(name: tag_name).joins(:package).where(packages_packages: { name: package_name })
  end

  def self.build_tags_hash(project, package_name)
    tags = {}
    find_tags_by_package(package_name).each do |tag|

      package = project.packages.find_by(id: tag.package_id)
      tags[tag.name] = package.version
    end
    tags
  end

end