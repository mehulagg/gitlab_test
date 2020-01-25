# frozen_string_literal: true

require 'base64'
require 'google/protobuf'
require 'gitaly'

module API
  module Internal
    class Praefect < Grape::API
      namespace 'internal' do
        namespace 'praefect' do
          desc 'gitaly HA node notifies gitlab of finishing write'
          params do
            requires :payload, type: String, desc: 'base64 encoded protobuf payload'
          end
          post "/finish-write" do
            repo = ::Gitaly::Repository.decode(
              Base64.strict_decode64(params['payload'])
            )

            primary_storage = ::Gitlab::Praefect.primary_storage(repo.storage_name)
            secondary_storages = ::Gitlab::Praefect.secondary_storages(repo.storage_name)

            secondary_storages.each do |target_storage|
              ::Praefect::ReplicationWorker.perform_async(
                target_storage,
                primary_storage,
                repo.relative_path,
                repo.gl_repository,
                repo.gl_project_path
              )
            end
          end
        end
      end
    end
  end
end
