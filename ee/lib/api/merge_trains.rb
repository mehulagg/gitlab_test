# frozen_string_literal: true

module API
  class MergeTrains < ::Grape::API
    before { authenticate! }

    helpers do
      def merge_request
        @merge_request ||= find_merge_request_with_access(params[:merge_request_iid])
      end
    end

    params do
      requires :id, type: String, desc: 'The ID of a project'
      requires :merge_request_iid, type: Integer, desc: 'The IID of a merge request'
    end
    resource :projects, requirements: ::API::API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
      segment ':id/merge_requests/:merge_request_iid/trains' do
        desc 'Get all entries on the merge train' do
          success ::EE::API::Entities::MergeTrain
        end
        get do
          merge_request = find_merge_request_with_access(params[:merge_request_iid])

          present MergeTrain.all_in_train(merge_request), with: ::EE::API::Entities::MergeTrain
        end

        desc 'Enqueue a merge request to a train' do
          success ::EE::API::Entities::MergeTrain
        end
        post 'enqueue' do
          begin
            merge_request.get_on_train!(current_user)

            present merge_request.merge_train, with: ::EE::API::Entities::MergeTrain, status: :ok
          rescue => e
            present { message: e.full_messages }, status: :bad_request
          end
      end

      segment ':id/merge_requests/:merge_request_iid/train' do
        desc 'Get the detail of the merge train' do
          success ::EE::API::Entities::MergeTrain
        end
        get do
          merge_request = find_merge_request_with_access(params[:merge_request_iid])

          present merge_request.merge_train, with: ::EE::API::Entities::MergeTrain, status: :ok
        end

        desc 'Dequeue a merge request from a train' do
          success ::EE::API::Entities::MergeTrain
        end
        post 'dequeue' do
          begin
            merge_request.get_off_train!

            present merge_request.merge_train, with: ::EE::API::Entities::MergeTrain, status: :ok
          rescue => e
            present { message: e.full_messages }, status: :bad_request
          end
        end
      end
    end
  end
end
