# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Packages::PackageTag, type: :model do
  describe 'relationships' do
    it { is_expected.to belong_to(:package) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:package) }
  end

  describe '#.find_tags_by_package' do
    let!(:package) { create(:npm_package) }
    let!(:package_tag) { create(:package_tag, package_id: package.id, project_id: package.project_id) }

    subject { described_class }

    it 'finds tag by package name' do
      expect(subject.find_tags_by_package(package.name)).to eq([package_tag])
    end
  end

  describe '.build_tags_hash' do


    let(:project)  { create(:project, name: 'project_name')}
    let(:package1) { create(:npm_package, version: '1.0.1', project: project)}
    let(:package2) { create(:npm_package, version: '1.0.1', project: project)}

    let(:package_tag1) { create(:package_tag, package_id: package1.id, name: 'latest', project_id: package1.project_id) }
    let(:package_tag2) { create(:package_tag, package_id: package2.id, name: 'next', project_id: package2.project_id) }
    let(:package_tag3) { create(:package_tag, package_id: package2.id, name: 'canary', project_id: package2.project_id) }

    let!(:packages_with_tags) { [package1, package2] }
    let(:tags) {
      {
        package_tag1[:name] => package1.version,
        package_tag2[:name] => package2.version,
        package_tag3[:name] => package2.version
      }
    }

    it 'receives an array of tagged packages' do
      allow(described_class).to receive(:find_tags_by_package).with(package1.name).and_return(tags)
    end

  end

end

