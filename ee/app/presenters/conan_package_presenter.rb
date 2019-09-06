# frozen_string_literal: true

class ConanPackagePresenter
  include API::Helpers::RelatedResourcesHelpers
  def initialize(recipe, user, project, package_id = nil)
    @recipe = recipe
    @user = user
    @project = project
    @package_id = package_id
  end

  def recipe_urls
    build_hash do |package_file|
      build_url(package_file) if package_file.conan_recipe_path?
    end
  end

  def recipe_snapshot
    build_hash do |package_file|
      package_file.file_md5 if package_file.conan_recipe_path?
    end
  end

  def package_urls
    build_hash do |package_file|
      build_url(package_file) if package_file.conan_package_path?
    end
  end

  def package_snapshot
    build_hash do |package_file|
      package_file.file_md5 if package_file.conan_package_path?
    end
  end

  private

  def build_url(package_file)
    "%{base}/api/v4/packages/conan/v1/files/%{recipe}/-/%{path}/%{file}" % {
      base: Settings.build_base_gitlab_url,
      recipe: package.conan_recipe_path,
      path: package_file.conan_file_metadatum.path,
      file: package_file.file_name
    }
  end

  def build_hash(&block)
    return {} unless package

    package_files.map do |package_file|
      next unless value = yield(package_file)

      [package_file.file_name, value]
    end.compact.to_h
  end

  def package_files
    @package_files ||= package.package_files.with_conan_file_metadata
  end

  def package
    @package ||= ::Packages::ConanPackageFinder
                   .new(@user, project: @project, recipe: @recipe).execute
  end
end
