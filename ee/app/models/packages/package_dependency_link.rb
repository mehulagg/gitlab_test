# frozen_string_literal: true
class Packages::PackageDependencyLink < ApplicationRecord
  belongs_to :package
  belongs_to :package_dependency
  validates :package, presence: true

  enum dependency_type: { dependencies: 10, devDependencies: 20, bundleDependencies: 30, peerDependencies: 40 }

  def self.find_or_create_by_dependency_type(package_dependency_id, dependency_type)
    dependency_link = Packages::PackageDependencyLink.find_by(dependency_type: dependency_type)

    return dependency_link if dependency_link && dependency_link.package_dependency_id == package_dependency_id

    Packages::PackageDependencyLink.create(package_dependency_id: package_dependency_id, dependency_type: dependency_type)
  end
end
