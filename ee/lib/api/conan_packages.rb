# frozen_string_literal: true

module API
  class ConanPackages < Grape::API
    helpers ::API::Helpers::PackagesHelpers

    before do
      not_found! unless Feature.enabled?(:conan_package_registry)
      require_packages_enabled!

      # Personal access token will be extracted from Bearer or Basic authorization
      # in the overridden find_personal_access_token helper
      authenticate!
    end

    namespace 'packages/conan/v1/users/' do
      format :txt

      desc 'Authenticate user against conan CLI' do
        detail 'This feature was introduced in GitLab 12.2'
      end
      get 'authenticate' do
        token = ::Gitlab::ConanToken.from_personal_access_token(access_token)
        token.to_jwt
      end

      desc 'Check for valid user credentials per conan CLI' do
        detail 'This feature was introduced in GitLab 12.3'
      end
      get 'check_credentials' do
        authenticate!
        :ok
      end
    end

    namespace 'packages/conan/v1/' do
      desc 'Ping the Conan API' do
        detail 'This feature was introduced in GitLab 12.2'
      end
      get 'ping' do
        header 'X-Conan-Server-Capabilities', [].join(',')
      end

      desc 'Search for packages' do
        detail 'This feature was introduced in GitLab 12.3'
      end
      params do
        requires :q, type: String, desc: 'Search query'
      end
      get 'conans/search' do
        service = ::Packages::Conan::SearchService.new(current_user, query: params[:q]).execute
        service.payload
      end
    end

    namespace 'packages/conan/v1/conans/*recipe_path' do
      before do
        render_api_error!("Invalid recipe", 400) unless valid_recipe_path?(params[:recipe_path])
      end
      params do
        requires :recipe_path, type: String, desc: 'Package recipe'
      end

      # Get the download urls
      #
      # returns the download urls for the existing recipe or package in the registry
      #
      # the manifest is a hash of { filename: url }
      # where the url is the download url for the file
      desc 'Package Download Urls' do
        detail 'This feature was introduced in GitLab 12.3'
      end
      get 'packages/:package_id/download_urls' do
        presenter = download_urls_presenter
        render_api_error!("No recipe manifest found", 404) if presenter.package_urls.empty?

        present presenter, with: EE::API::Entities::ConanPackage::ConanPackageManifest
      end

      desc 'Recipe Download Urls' do
        detail 'This feature was introduced in GitLab 12.3'
      end
      get 'download_urls' do
        presenter = download_urls_presenter
        render_api_error!("No recipe manifest found", 404) if presenter.recipe_urls.empty?

        present presenter, with: EE::API::Entities::ConanPackage::ConanRecipeManifest
      end

      # Get the recipe manifest
      # returns the download urls for the existing recipe in the registry
      #
      # the manifest is a hash of { filename: url }
      # where the url is the download url for the file
      desc 'Package Digest' do
        detail 'This feature was introduced in GitLab 12.3'
      end
      get 'packages/:package_id/digest' do
        presenter = download_urls_presenter
        render_api_error!("No recipe manifest found", 404) if presenter.package_urls.empty?

        present presenter, with: EE::API::Entities::ConanPackage::ConanPackageManifest
      end

      desc 'Recipe Digest' do
        detail 'This feature was introduced in GitLab 12.3'
      end
      get 'digest' do
        presenter = download_urls_presenter
        render_api_error!("No recipe manifest found", 404) if presenter.recipe_urls.empty?

        present presenter, with: EE::API::Entities::ConanPackage::ConanRecipeManifest
      end

      # Get the upload urls
      #
      # request body contains { filename: filesize } where the filename is the
      # name of the file the conan client is requesting to upload
      #
      # returns { filename: url }
      # where the url is the upload url for the file that the conan client will use
      desc 'Package Upload Urls' do
        detail 'This feature was introduced in GitLab 12.3'
      end
      params do
        requires :package_id, type: String, desc: 'Conan package ID'
      end
      post 'packages/:package_id/upload_urls' do
        status 200
        {
          'conaninfo.txt':      "#{base_file_url}/#{params[:recipe_path]}/-/0/package/#{params[:package_id]}/0/conaninfo.txt",
          'conanmanifest.txt': "#{base_file_url}/#{params[:recipe_path]}/-/0/package/#{params[:package_id]}/0/conanmanifest.txt",
          'conan_package.tgz': "#{base_file_url}/#{params[:recipe_path]}/-/0/package/#{params[:package_id]}/0/conan_package.tgz"
        }
      end

      desc 'Recipe Upload Urls' do
        detail 'This feature was introduced in GitLab 12.3'
      end
      post 'upload_urls' do
        status 200
        {
          'conanfile.py':      "#{base_file_url}/#{params[:recipe_path]}/-/0/export/conanfile.py",
          'conanmanifest.txt': "#{base_file_url}/#{params[:recipe_path]}/-/0/export/conanmanifest.txt"
        }
      end

      # Get the recipe snapshot
      #
      # the snapshot is a hash of { filename: md5 hash }
      # md5 hash is the has of that file. This hash is used to diff the files existing on the client
      # to determine which client files need to be uploaded if no recipe exists the snapshot is empty
      desc 'Package Snapshot' do
        detail 'This feature was introduced in GitLab 12.3'
      end
      get 'packages/:package_id' do
        recipe = generate_recipe(params[:recipe_path])
        project = find_project_by_recipe(params[:recipe_path])

        authorize!(:read_package, project)
        presenter = ConanPackagePresenter.new(recipe, current_user, project, params[:package_id])
        present presenter, with: EE::API::Entities::ConanPackage::ConanPackageSnapshot
      end

      desc 'Recipe Snapshot' do
        detail 'This feature was introduced in GitLab 12.3'
      end
      get '/' do
        recipe = generate_recipe(params[:recipe_path])
        project = find_project_by_recipe(params[:recipe_path])

        authorize!(:read_package, project)
        presenter = ConanPackagePresenter.new(recipe, current_user, project)
        present presenter, with: EE::API::Entities::ConanPackage::ConanRecipeSnapshot
      end

      desc 'Delete Package' do
        detail 'This feature was introduced in GitLab 12.4'
      end
      delete '/' do
        recipe = generate_recipe(params[:recipe_path])
        project = find_project_by_recipe(params[:recipe_path])

        render_api_error!("No GitLab project found", 404) unless project
        authorize!(:destroy_package, project)

        package = ::Packages::ConanPackageFinder
                    .new(current_user, recipe: recipe, project: project).execute

        package.destroy
      end
    end

    namespace 'packages/conan/v1/files/*recipe_path/-/*path/' do
      before do
        render_api_error!("Invalid recipe", 400) unless valid_recipe_path?(params[:recipe_path])
      end
      params do
        requires :recipe_path, type: String, desc: 'Package recipe'
        requires :path, type: String, desc: 'Package path'
      end

      desc 'Upload the conan package file' do
        detail 'This feature was introduced in GitLab 11.3'
      end
      # route_setting :authentication, job_token_allowed: true
      put 'authorize' do
        project = find_project_by_recipe(params[:recipe_path])

        authorize!(:create_package, project)
        require_gitlab_workhorse!
        Gitlab::Workhorse.verify_api_request!(headers)

        status 200
        content_type Gitlab::Workhorse::INTERNAL_API_CONTENT_TYPE
        ::Packages::PackageFileUploader.workhorse_authorize(has_length: true)
      end

      desc 'Upload package files' do
        detail 'This feature was introduced in GitLab 12.3'
      end
      params do
        requires :file_name, type: String, desc: 'Package file name'
        optional 'file.path', type: String, desc: %q(path to locally stored body (generated by Workhorse))
        optional 'file.name', type: String, desc: %q(real filename as send in Content-Disposition (generated by Workhorse))
        optional 'file.type', type: String, desc: %q(real content type as send in Content-Type (generated by Workhorse))
        optional 'file.size', type: Integer, desc: %q(real size of file (generated by Workhorse))
        optional 'file.md5', type: String, desc: %q(md5 checksum of the file (generated by Workhorse))
        optional 'file.sha1', type: String, desc: %q(sha1 checksum of the file (generated by Workhorse))
        optional 'file.sha256', type: String, desc: %q(sha256 checksum of the file (generated by Workhorse))
      end
      put ':file_name' do
        project = find_project_by_recipe(params[:recipe_path])
        forbidden! unless project.feature_available?(:packages)

        render_api_error!("No GitLab project found", 404) unless project

        authorize!(:create_package, project)
        require_gitlab_workhorse!

        uploaded_file = UploadedFile.from_params(params, :file, ::Packages::PackageFileUploader.workhorse_local_upload_path)
        bad_request!('Missing package file!') unless uploaded_file

        recipe = generate_recipe(params[:recipe_path])

        package = ::Packages::Conan::FindOrCreatePackageService
                    .new(project, current_user, params.merge(recipe: recipe)).execute

        file_params = {
          file:      uploaded_file,
          size:      params['file.size'],
          file_name: "#{params[:file_name]}.#{params[:format]}",
          file_type: params['file.type'],
          file_sha1: params['file.sha1'],
          file_md5:  params['file.md5'],
          path:      params[:path],
          recipe:    recipe
        }

        ::Packages::Conan::CreatePackageFileService.new(package, file_params).execute unless params['file.size'] == 0
      end
    end

    namespace 'packages/conan/v1/files/*recipe_path/-/*path/' do
      before do
        render_api_error!("Invalid recipe", 400) unless valid_recipe_path?(params[:recipe_path])
      end
      params do
        requires :recipe_path, type: String, desc: 'Package recipe'
        requires :path, type: String, desc: 'Package path'
      end

      desc 'Download package files' do
        detail 'This feature was introduced in GitLab 12.4'
      end
      params do
        requires :recipe_path, type: String, desc: 'Package recipe'
        requires :path, type: String, desc: 'Package path'
        requires :file_name, type: String, desc: 'Package file name'
      end
      get ':file_name' do
        recipe = generate_recipe(params[:recipe_path])
        project = find_project_by_recipe(params[:recipe_path])

        render_api_error!("No GitLab project found", 404) unless project
        authorize!(:read_package, project)
        forbidden! unless project.feature_available?(:packages)

        package = ::Packages::ConanPackageFinder
                    .new(current_user, recipe: recipe, project: project).execute

        package_file = ::Packages::PackageFileFinder
                         .new(package, "#{params[:file_name]}.#{params[:format]}").execute!

        present_carrierwave_file!(package_file.file)
      end
    end

    helpers do
      def base_file_url
        "#{::Settings.gitlab.base_url}/api/v4/packages/conan/v1/files"
      end

      def parse_recipe(recipe_path)
        split_recipe = recipe_path.split('/')
        {
          package_name: split_recipe[0],
          version: split_recipe[1],
          pkg_username: split_recipe[2],
          channel: split_recipe[3]
        }
      end

      def generate_recipe(recipe_path)
        recipe_obj = parse_recipe(recipe_path)
        "#{recipe_obj[:package_name]}/#{recipe_obj[:version]}@#{recipe_obj[:pkg_username]}/#{recipe_obj[:channel]}"
      end

      def find_project_by_recipe(recipe_path)
        project_path = parse_recipe(recipe_path)[:pkg_username].tr('+', '/')
        Project.find_by_full_path(project_path)
      end

      def find_personal_access_token
        personal_access_token = find_personal_access_token_from_conan_jwt ||
          find_personal_access_token_from_conan_http_basic_auth

        personal_access_token || unauthorized!
      end

      # We need to override this one because it
      # looks into Bearer authorization header
      def find_oauth_access_token
      end

      def find_personal_access_token_from_conan_jwt
        jwt = Doorkeeper::OAuth::Token.from_bearer_authorization(current_request)
        return unless jwt

        token = ::Gitlab::ConanToken.decode(jwt)
        return unless token&.personal_access_token_id && token&.user_id

        PersonalAccessToken.find_by_id_and_user_id(token.personal_access_token_id, token.user_id)
      end

      def find_personal_access_token_from_conan_http_basic_auth
        encoded_credentials = headers['Authorization'].to_s.split('Basic ', 2).second
        token = Base64.decode64(encoded_credentials || '').split(':', 2).second
        return unless token

        PersonalAccessToken.find_by_token(token)
      end

      def valid_recipe_path?(recipe_path)
        recipe_path =~ %r{\A(([\w](\.|\+|-)?)*(\/?)){4}\z}
      end

      def download_urls_presenter
        recipe = generate_recipe(params[:recipe_path])
        project = find_project_by_recipe(params[:recipe_path])
        render_api_error!("No recipe manifest found", 404) unless project

        ConanPackagePresenter.new(recipe, current_user, project, params[:package_id])
      end
    end
  end
end
