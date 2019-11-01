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
      package_file = package.package_files.last
      package_dependency_links = package.package_dependency_links
      package_versions[package.version] = if package_dependency_links.present?
                                            build_package_version(package, package_file).merge(traverse_dependencies(package_dependency_links))
                                          else
                                            package_versions[package.version] = build_package_version(package, package_file)
                                          end
    end
    package_versions
  end

  def dist_tags
    tagged_packages
  end

  private

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

  def traverse_dependencies(package_links)
    dependency_hash = Hash.new { |hash, dep_type| hash[dep_type] = {} }
    package_links.each do |dependency_link|
      package_dependency = Packages::PackageDependency.find(dependency_link.package_dependency_id)
      dependency_hash[dependency_link.dependency_type].store package_dependency.name, package_dependency.version_pattern
    end
    dependency_hash
  end
end
