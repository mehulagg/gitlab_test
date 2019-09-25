# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Packages::PackageTag, type: :model do
  let!(:project) { create(:project) }
  let!(:package) { create(:npm_package, version: '1.0.2', project: project) }

  describe 'relationships' do
    it { is_expected.to belong_to(:package) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:package) }
  end

  describe '.with_package_name' do
    let!(:tagged_package1) { create(:package_tag, package_id: package.id, name: 'latest') }
    let!(:tagged_package2) { create(:package_tag, package_id: package.id) }
    subject { described_class.with_package_name(package.name) }

    it 'finds tag by package name' do
      is_expected.to include(tagged_package1, tagged_package2)
    end
  end

  describe '.with_tag_name_and_package_name' do
    let(:package_tag) { create(:package_tag, package: package, name: 'stable') }
    subject { described_class.with_package_name(package.name) }

    it 'finds package by tag and package name' do
      expect(subject.with_tag_name_and_package_name("stable", package.name)).to include(package_tag)
      is_expected.to include(package_tag)
    end
  end

  describe '.build_tags_hash_for' do
    let!(:package_tag1) { create(:package_tag, package: package, name: 'stable') }
    let!(:package_tag2) { create(:package_tag, package: package, name: 'next') }
    let!(:package_tag3) { create(:package_tag, package: package, name: 'canary') }

    let(:tags) do
      {
        'stable' => package.version,
        'next' => package.version,
        'canary' => package.version
      }
    end

    subject { described_class }

    it 'returns a hash of package name and their corresponding version' do
      expect(subject.build_tags_hash_for(package.name)).to eq(tags)
    end
  end
end
