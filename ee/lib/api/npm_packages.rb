# frozen_string_literal: true
module API
  class NpmPackages < Grape::API
    NPM_ENDPOINT_REQUIREMENTS = {
      package_name: API::NO_SLASH_URL_PART_REGEX
    }.freeze

    rescue_from ActiveRecord::RecordInvalid do |e|
      render_api_error!(e.message, 400)
    end

    before do
      require_packages_enabled!
      authenticate_non_get!
    end

    helpers ::API::Helpers::PackagesHelpers

    helpers do
      def find_project_by_package_name(name)
        ::Packages::Package.npm.with_name(name).first&.project
      end

      def find_package(project, package_name)
        ::Packages::NpmPackagesFinder.new(project, package_name).execute
      end

      def find_package_by_name_and_version(package_name, version)
        ::Packages::Package.by_name_and_version(package_name, version)
      end

      def tagged_packages(project, package_name)
        ::Packages::PackageTag.build_tags_hash(project, package_name)
      end

      def find_tagged_package_by_name(package_name, tag)
        ::Packages::PackageTag.find_by_package_name(package_name, tag).last!
      end

      def build_request(package_name, type)
        project = find_project_by_package_name(package_name)
        packages = find_package(project, package_name)

        authorize!(:read_package, project)
        forbidden! unless project.feature_available?(:packages)

        present NpmPackagePresenter.new(project, package_name, packages, tagged_packages(project, package_name)),
                with: EE::API::Entities::NpmPackage, type: type
      end

      def authorize_feature(project)
        authorize!(:read_package, project)
        forbidden! unless project.feature_available?(:packages)
      end

    end

    desc 'Dist Tag Endpoints' do
      detail 'Access packages by their respective tags'
    end

    params do
      requires :package_name, type: String, desc: 'Package name'
      optional :tag, type: String, desc: "Package dist-tag"
    end

    get 'packages/npm/-/package/*package_name/dist-tags', format: false, requirements: NPM_ENDPOINT_REQUIREMENTS do
      build_request(params[:package_name], 'tags')
    end

    put 'packages/npm/-/package/*package_name/dist-tags/:tag', format: false, requirements: NPM_ENDPOINT_REQUIREMENTS do

      package_name = params[:package_name]
      tag = params[:tag]
      version = env['api.request.body']

      project = find_project_by_package_name(package_name)
      package = find_package_by_name_and_version(package, version)

      authorize_feature(project)

      ::Packages::CreateNpmPackageTagService.new(package, tagged_packages(project, package_name), tag).execute
    end

    params do
      requires :package_name, type: String, desc: 'Package name'
      optional :tag, type: String, desc: "Package dist-tag"
    end

    delete 'packages/npm/-/package/*package_name/dist-tags/:tag', format: false, requirements: NPM_ENDPOINT_REQUIREMENTS do
      package_name = params[:package_name]
      tag = params[:tag]

      project = find_project_by_package_name(package_name)
      package_tag = find_tagged_package_by_name(package_name, tag)

      authorize_feature(project)
      ::Packages::RemoveNpmPackageTagService.new(project, package_tag).execute
    end

    get 'packages/npm/*package_name', format: false, requirements: NPM_ENDPOINT_REQUIREMENTS do
      build_request(params[:package_name], 'versions')
    end

    desc 'NPM registry endpoint at instance level' do
      detail 'This feature was introduced in GitLab 11.8'
    end

    params do
      requires :id, type: String, desc: 'The ID of a project'
    end
    resource :projects, requirements: API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
      before do
        authorize_packages_feature!
      end

      desc 'Download the NPM tarball' do
        detail 'This feature was introduced in GitLab 11.8'
      end
      params do
        requires :package_name, type: String, desc: 'Package name'
        requires :file_name, type: String, desc: 'Package file name'
      end
      get ':id/packages/npm/*package_name/-/*file_name', format: false do
        authorize_download_package!

        package = user_project.packages.npm
          .by_name_and_file_name(params[:package_name], params[:file_name])

        package_file = ::Packages::PackageFileFinder
          .new(package, params[:file_name]).execute!

        present_carrierwave_file!(package_file.file)
      end

      desc 'Create NPM package' do
        detail 'This feature was introduced in GitLab 11.8'
      end
      params do
        requires :package_name, type: String, desc: 'Package name'
        requires :versions, type: Hash, desc: 'Package version info'
      end
      put ':id/packages/npm/:package_name', requirements: NPM_ENDPOINT_REQUIREMENTS do
        authorize_create_package!

        created_package = ::Packages::CreateNpmPackageService
          .new(user_project, current_user, params).execute

        if created_package[:status] == :error
          render_api_error!(created_package[:message], created_package[:http_status])
        else
          created_package
        end
      end
    end
  end
end
