# frozen_string_literal: true
class Packages::PackageDependencyLink < ApplicationRecord
  belongs_to :package
  belongs_to :package_dependency
  validates :package, presence: true

  enum dependency_type: { dependencies: 10, devDependencies: 20, bundleDependencies: 30, peerDependencies: 40 }

end
