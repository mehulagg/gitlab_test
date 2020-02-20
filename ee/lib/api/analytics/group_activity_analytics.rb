# frozen_string_literal: true

module API
  module Analytics
    class GroupActivityAnalytics < Grape::API
      before do
        authenticate!
        not_found! unless Feature.enabled?(:group_activity_analytics)
      end

      helpers do
        def group
          @group ||= find_group!(params[:group_path])
        end
      end

      resource :analytics do
        desc 'List recent activity information about group' do
          detail 'This feature is gated by the `:group_activity_analytics`'\
                 'feature flag, introduced in GitLab 12.9.'
          success EE::API::Entities::Analytics::GroupActivity
        end
        params do
          requires :group_path, type: String, desc: 'Group Path'
        end
        get 'group_activity' do
          authorize! :read_group_activity_analytics, group

          present(
            ::Analytics::GroupActivityCalculator.new(group, current_user),
            with: EE::API::Entities::Analytics::GroupActivity
          )
        end
      end
    end
  end
end
