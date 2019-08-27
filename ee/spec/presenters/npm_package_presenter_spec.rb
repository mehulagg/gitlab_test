# frozen_string_literal: true

require 'spec_helper'

describe NpmPackagePresenter do
  set(:project) { create(:project) }
  set(:package) { create(:npm_package, version: '1.0.4', project: project) }
  set(:latest_package) { create(:npm_package, version: '1.0.11', project: project, package_tags: []) }

  let (:package_tags) { { "latest": "1.0.4"} }
  set(:packages) { [package, latest_package] }
  let(:presenter) { described_class.new(project, package.name, packages, package_tags, 'tags') }

  describe 'dist_tags' do

    set (:package_metadatum) { create(:package_metadatum, package_id: package.id, metadata: "{\"name\": \"#{package.name}\", \"version\": \"#{package.version}\", \"dist\": {\"shasum\": \"hello\", \"tarball\": \"http://gitlab.example.com/v4/api/packages/npm\"},\"bundleDependencies\": {}, \"peerDependencies\": {}, \"deprecated\": \"\", \"engines\": {}}") }
    set(:latest_package) { create(:npm_package, version: '1.0.11', project: project, package_tags: []) }
    set (:latest_metadatum) { create(:package_metadatum, package_id: latest_package.id, metadata: "{\"name\": \"#{latest_package.name}\", \"version\": \"#{latest_package.version}\",\"dist\": {\"shasum\": \"hello\", \"tarball\": \"http://gitlab.example.com/v4/api/packages/npm\"}, \"bundleDependencies\": {}, \"peerDependencies\": {}, \"deprecated\": \"\", \"engines\": {}}") }

    set(:latest_tag) { create(:package_tag, name: 'next', package: latest_package) }

    it { expect(presenter.dist_tags).to be_a(Hash) }
    it { expect(presenter.dist_tags).to match_schema('public_api/v4/packages/npm_package_tags', dir: 'ee') }

    context "when a package only has one tag" do
      let (:package_tags) { { "latest": "1.0.4" }}

      it "returns a hash with the corresponding version" do
        expect(presenter.dist_tags).to eq(package_tags)
      end

    end

    context "when a package has multiple tags" do

      let (:package_tags) { { "latest": "1.0.4", "next": '1.0.11'} }

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
      set(:older_package2) { create(:npm_package, version: '1.1.3', project: project)}
      let(:packages) { [older_package1, older_package2]}
      let(:package_tags) { { "latest": "1.0.2" } }
      let(:versions) { { "#{older_package1.version}" => { :dist => { :shasum =>"#{older_package1.package_files.last.file_sha1}", :tarball => "#{expose_url api_v4_projects_path(id: older_package1.project_id)}/packages/npm/#{older_package1.name}/-/#{older_package1.package_files.last.file_name}"}, :name=>"#{older_package1.name}", :version => "#{older_package1.version}"}, "1.1.3" => { :dist => { :shasum => "#{older_package1.package_files.last.file_sha1}", :tarball => "#{expose_url api_v4_projects_path(id: older_package2.project_id)}/packages/npm/#{older_package2.name}/-/#{older_package2.package_files.last.file_name}"}, :name => "#{older_package2.name}", :version => "#{older_package2.version}" } } }

      subject {described_class.new(project, older_package1.name, packages, package_tags, 'tags')}
      it "Builds the package hash from package_files instead of the package_metadatum.metadata" do
        expect(older_package1.package_metadatum.metadata.empty?).to eq(true)
        expect(subject.versions).to be_a(Hash)
        expect(subject.versions).to eq(versions)
      end

    end

  end




end
