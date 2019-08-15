# frozen_string_literal: true

class NpmPackagePresenter
  include API::Helpers::RelatedResourcesHelpers

  attr_reader :project, :name, :packages, :tagged_packages

  def initialize(project, name, packages, tagged_packages, type)
    @project = project
    @name = name
    @packages = packages
    @tagged_packages = tagged_packages
  end

  def versions
    package_versions = {}
    packages.each do |package|
      package_file = package.package_files.last
      package_versions[package.version] = build_package_version(package, package_file)
      package_metadatum = package.package_metadatum
      if !package_metadatum.nil? && !package_metadatum.metadata.empty?
        parsed_metadata = JSON.parse(package_metadatum.metadata).with_indifferent_access
        package_versions[package.version] = build_metadata(parsed_metadata)
      else
        package_versions[package.version] = build_package_version(package, package_file)
      end
    end
    package_versions
  end

  def dist_tags
    {
      latest: sorted_versions.last
    }
  end

  private

  def build_metadata(package_json)
    {
        name: package_json[:name],
        version: package_json[:version],
        dist: package_json[:dist],
        dependencies: package_json[:dependencies],
        optionalDependencies: package_json[:dependencies],
        devDependencies: package_json[:devDependencies],
        directories: package_json[:directories],
        bundleDependencies: package_json[:bundleDependencies],
        peerDependencies: package_json[:peerDependencies],
        deprecated: package_json[:deprecated],
        entities: package_json[:engines],
        bin: package_json[:bin]
    }
  end

  def build_package_version(package, package_file)
    {
        name: package.name,
        version: package.version,
        dist: {
            shasum: package_file.file_sha1,
            tarball: tarball_url(package, package_file)
        }
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
