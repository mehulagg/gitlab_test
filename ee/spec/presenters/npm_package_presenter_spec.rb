# frozen_string_literal: true

require 'spec_helper'

describe NpmPackagePresenter do
  let(:project) { create(:project) }
  let(:package) { create(:npm_package, version: '1.0.4', project: project) }
  let(:latest_package) { create(:npm_package, version: '1.0.11', project: project, package_tags: []) }
  let(:package_tags) { { 'latest': '1.0.4', 'next': '1.0.11' } }
  let(:packages) { [package, latest_package] }
  let(:dist_object) { { shasum: "verylongsha", tarball: "http://gitlab.example.com/v4/api/packages/npm" } }
  let(:dependencies) { { bundleDependencies: {}, peerDependencies: {}, deprecated: "", engines: {} } }
  let(:package_metadatum) { create(:package_metadatum, package_id: package.id, metadata: { name: package.name, version: package.version, dist: dist_object }.to_json ) }
  let(:presenter) { described_class.new(project, package.name, packages, package_tags, 'tags') }

  describe '#dist_tags' do
    it { expect(presenter.dist_tags).to be_a(Hash) }
    it { expect(presenter.dist_tags).to match_schema('public_api/v4/packages/npm_package_tags', dir: 'ee') }

    context "when a package only has one tag" do
      let(:package_tags) { { "latest": "1.0.4" }}

      it "returns a hash with the corresponding version" do
        expect(presenter.dist_tags).to eq(package_tags)
      end
    end

    context "when a package has multiple tags" do
      it "returns a hash with all tags and corresponding versions" do
        expect(presenter.dist_tags).to eq(package_tags)
      end
    end

    context "The package tagged latest is not the latest package to be upload'" do
      it "returns the package with the tag 'latest'" do
        expect(presenter.dist_tags[:latest]).to eq("1.0.4")
      end
    end
  end

  describe '#versions' do
    it { expect(presenter.versions).to be_a(Hash) }
    it { expect(presenter.versions[package.version]).to match_schema('public_api/v4/packages/npm_package_version', dir: 'ee') }
    it { expect(presenter.versions[latest_package.version]).to match_schema('public_api/v4/packages/npm_package_version', dir: 'ee') }

    # For older packages without metadata
    context "Returns package if it doesn't have metadata as long as the package exists" do
      let(:older_package1) { create(:npm_package, version: '1.0.2', project: project) }
      let(:older_package2) { create(:npm_package, version: '1.1.3', project: project) }
      let(:packages) { [older_package1, older_package2] }
      let(:package_tags) { { "latest": "1.0.2" } }
      let(:package1_version) { older_package1.version }
      let(:package2_version) { older_package2.version }

      subject { described_class.new(project, older_package1.name, packages, package_tags, 'tags') }

      it "builds the package hash from package_files instead of the package_metadatum.metadata" do
        versions =
          {
            package1_version =>
              {
                dist: {
                  shasum: older_package1.package_files.last.file_sha1,
                  tarball: build_package_tarball(older_package1.project_id, older_package1.name, older_package1.package_files.last.file_name)
                },
                name: older_package1.name,
                version: package1_version
              },
            package2_version =>
              {
                dist: {
                  shasum: older_package1.package_files.last.file_sha1,
                  tarball: build_package_tarball(older_package2.project_id, older_package2.name, older_package1.package_files.last.file_name)
                },
                name: older_package2.name,
                version: older_package2.version
              }
          }
        expect(older_package1.package_metadatum.present?).to eq(false)
        expect(subject.versions).to eq(versions)
      end
    end

    def build_package_tarball(project_id, package_name, package_file)
      "#{expose_url api_v4_projects_path(id: project_id)}/packages/npm/#{package_name}/-/#{package_file}"
    end
  end
end
