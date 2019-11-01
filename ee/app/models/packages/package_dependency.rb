# frozen_string_literal: true
class Packages::PackageDependency < ApplicationRecord
  belongs_to :package
  has_many :package_dependency_links
  validates :package, presence: true

  def self.find_or_create_by_version_pattern(name, version_pattern)
    package_dependency = Packages::PackageDependency.find_by(version_pattern: version_pattern)

    return package_dependency if package_dependency && package_dependency.name == name

    Packages::PackageDependency.create(name: name, version_pattern: version_pattern)
  end
end
