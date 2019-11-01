# frozen_string_literal: true
FactoryBot.define do
  factory :package_dependency_link, class: Packages::PackageDependencyLink do
    package
    package_dependency
  end
end
