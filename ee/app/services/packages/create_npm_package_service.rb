# frozen_string_literal: true
module Packages
  class CreateNpmPackageService < BaseService
    def execute
      return error('Invalid package name', 400) unless valid_package_name
      return error('Package name is already taken.', 403) if @project.package_already_taken?(params[:name])

      name = params[:name]
      version = params[:versions].keys.first
      version_data = params[:versions][version]

      existing_package = project.packages.npm.with_name(name).with_version(version)

      return error('Package already exists.', 403) unless existing_package.blank?

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

      ::Packages::CreatePackageFileService.new(package, file_params).execute

      package
    end

    private

    def valid_package_name
      params[:name] =~ %r{\A@#{@project.namespace.root_ancestor.path}/[^/]+\z}
    end
  end
end
