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

  describe '#.find_tags_by_package' do
    let!(:tagged_package1) { create(:package_tag, package_id: package.id, name: "latest") }
    let!(:tagged_package2) { create(:package_tag, package_id: package.id) }

    subject { described_class }
    it 'finds tag by package name' do
      expect(subject.find_tags_by_package(package.name)).to include(tagged_package1, tagged_package2)
    end
  end

  describe '#.find_packages_by_package_tag' do
    subject { described_class }
    let(:package_tag) { create(:package_tag, package_id: package.id, name: 'stable') }

    it 'finds package by tag and package name' do
      expect(subject.find_packages_by_package_tag("stable", package.name)).to include(package_tag)
    end
  end

  describe '#.build_tags_hash' do
    let!(:package_tag1) { create(:package_tag, package: package, name: 'stable') }
    let!(:package_tag2) { create(:package_tag, package: package, name: 'next') }
    let!(:package_tag3) { create(:package_tag, package: package, name: 'canary') }

    let(:tags) { { package_tag1[:name] => package.version, package_tag2[:name] => package.version, package_tag3[:name] => package.version } }

    subject { described_class }

    it 'returns a hash of package name and their corresponding version' do
      expect(subject.build_tags_hash(project, package.name)).to eq(tags)
    end
  end
end
