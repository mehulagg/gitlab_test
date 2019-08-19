# frozen_string_literal: true

class NpmPackagePresenter
  include API::Helpers::RelatedResourcesHelpers

  attr_reader :project, :name, :packages, :tagged_packages, :type

  def initialize(project, name, packages, tagged_packages, type)
    @project = project
    @name = name
    @packages = packages
    @tagged_packages = tagged_packages
    @type = type
  end

  def versions
    package_versions = {}
    packages.each do |package|
      if package.package_metadatum != nil
        package_metadatum = package.package_metadatum.nil? ? "" : JSON.parse(package.package_metadatum.metadata).with_indifferent_access
        package_versions[package.version] = build_metadata(package_metadatum)

      end
    end

    package_versions
  end

  def dist_tags
    tagged_packages
  end

  private

  def build_metadata(package_json)
    {
        name: package_json[:name],
        version: package_json[:version],
        dependencies: package_json[:dependencies],
        optionalDependencies: package_json[:dependencies],
        devDependencies: package_json[:devDependencies],
        directories: package_json[:directories],
        dist: package_json[:dist],
        bundleDependencies: package_json[:bundleDependencies],
        peerDependencies: package_json[:peerDependencies],
        deprecated: package_json[:deprecated],
        bin: package_json[:bin]
    }
  end

  def tarball_url(package, package_file)
    expose_url "#{api_v4_projects_path(id: package.project_id)}" \
      "/packages/npm/#{package.name}" \
       "/-/#{package_file.file_name}"
  end

  def sorted_versions
    versions = packages.map(&:version).compact
    VersionSorter.sort(versions)
  end
end
