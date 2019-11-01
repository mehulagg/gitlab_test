# frozen_string_literal: true
FactoryBot.define do
  factory :package_dependency, class: Packages::PackageDependency do
    package
  end
end
