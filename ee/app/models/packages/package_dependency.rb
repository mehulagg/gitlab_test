# frozen_string_literal: true
class Packages::PackageDependency < ApplicationRecord
  belongs_to :package
  has_many :package_dependency_links
  validates :package, presence: true
end
