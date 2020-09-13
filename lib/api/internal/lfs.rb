# frozen_string_literal: true

module API
  # Pages Internal API
  module Internal
    class Lfs < Grape::API::Instance
      before do
        authenticate_gitlab_lfs_smudge_filter_request!
      end

      helpers do
        def authenticate_gitlab_lfs_smudge_filter_request!
          # TODO
        end

        def find_lfs_object(lfs_oid)
          LfsObject.find_by_oid(lfs_oid)
        end
      end

      namespace 'internal' do
        namespace 'lfs' do
          desc 'Get LFS URL for object ID' do
            detail 'This feature was introduced in GitLab 13.5.'
          end
          params do
            requires :oid, type: String, desc: 'The object ID to query'
          end
          get "/" do
            lfs_object = find_lfs_object(params[:oid])

            not_found! unless lfs_object
            not_found! if lfs_object.file_store == LfsObjectUploader::Store::LOCAL

            url = lfs_object.file&.url

            not_found! unless url.present?

            data = { url: url }
            body data
            status :ok
          end
        end
      end
    end
  end
end
