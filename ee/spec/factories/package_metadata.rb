FactoryBot.define do
  factory :package_metadatum, class: Packages::PackageMetadatum do
    package
    metadata ""
  end
end
