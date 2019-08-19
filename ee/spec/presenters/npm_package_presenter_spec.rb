# frozen_string_literal: true

require 'spec_helper'

describe NpmPackagePresenter do
  set(:project) { create(:project) }
  set(:package) { create(:npm_package, version: '1.0.4', project: project) }

  set(:latest_package) { create(:npm_package, version: '1.0.11', project: project, package_tags: []) }

  let(:presenter) { described_class.new(project, package.name, packages, package_tag.all) }

  describe '#dist_tags' do
    it { expect(presenter.dist_tags).to be_a(Hash) }
    # The latest tag is not necessarily the latest package to be published. By default, if a package is untagged, and no other has the "latest" tag,
    # it will be marked as latest
  end

  describe '#versions' do
    it { expect(presenter.versions).to be_a(Hash) }
    it { expect(presenter.versions[package.version]).to match_schema('public_api/v4/packages/npm_package_version', dir: 'ee') }
  end
end
