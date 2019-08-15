# frozen_string_literal: true
class Packages::PackageTagsFinder
  attr_reader :project, :package_name, :tag

  def initialize(project, package_name, tag)
    @project = project
    @package_name = package_name
  end

  def execute
    packages
  end

  private

  def packages
    project.packages
        .with_tag(tag)
  end
end
