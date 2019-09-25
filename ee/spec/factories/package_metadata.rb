FactoryBot.define do
  factory :package_metadatum, class: Packages::PackageMetadatum do
    package
    metadata { fixture_file('ee/spec/fixtures/npm/metadata') }
  end
end
