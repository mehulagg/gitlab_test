# frozen_string_literal: true
module Packages
  class CreateNpmPackageService < BaseService
    def execute
      name = params[:name]
      version = params[:versions].keys.first

      version_data = params[:versions][version]
      dist_tag = params[:'dist-tags'].keys.first
      existing_package = project.packages.npm.with_name(name).with_version(version)

      return error('Package already exists.', 403) if existing_package.exists?

      package = project.packages.create!(
        name: name,
        version: version,
        package_type: 'npm'
      )

      package_file_name = "#{name}-#{version}.tgz"
      attachment = params['_attachments'][package_file_name]

      file_params = {
        file:      CarrierWaveStringFile.new(Base64.decode64(attachment['data'])),
        size:      attachment['length'],
        file_sha1: version_data[:dist][:shasum],
        file_name: package_file_name
      }

      ::Packages::PackageTag.transaction do
        ::Packages::CreatePackageFileService.new(package, file_params).execute
        ::Packages::CreatePackageMetadataService.new(package, package_metadata).execute
        ::Packages::CreateNpmPackageTagService.new(package, dist_tag).execute
      end
      package
    end

    def package_metadata
      package_json = params[:versions]
      version = params[:versions].keys.first

      package_json[version].to_json
    end
  end
end
