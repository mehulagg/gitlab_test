# frozen_string_literal: true

require 'spec_helper'

describe Projects::GroupLinksController do
  let(:group) { create(:group, :private) }
  let(:group2) { create(:group, :private) }
  let(:project) { create(:project, :private, group: group2) }
  let(:user) { create(:user) }
  let!(:gitlab_subscription) { create(:gitlab_subscription, namespace: project.namespace) }
  let(:link_params) do
    { namespace_id: project.namespace,
      project_id: project,
      link_group_id: group.id,
      link_group_access: ProjectGroupLink.default_access }
  end

  before do
    allow(Gitlab::CurrentSettings.current_application_settings)
      .to receive(:should_check_namespace_plan?) { true }

    group.add_developer(user)
    project.add_maintainer(user)
    sign_in(user)
  end

  describe 'POST #create' do
    it 'updates the max_seats_used counter' do
      expect(::Gitlab::Subscription::MaxSeatsUpdater)
        .to receive(:update).with(project).and_call_original

      post(:create, params: link_params)

      expect(response).to redirect_to(project_project_members_path(project))
      expect(ProjectGroupLink.count).to eq(1)
      expect(gitlab_subscription.reload.max_seats_used).to eq(1)
    end
  end

  describe 'PUT #update' do
    let!(:group_link) { create_group_link }

    context 'when updating the access level of the link' do
      let(:update_params) do
        { id: group_link.id,
          namespace_id: project.namespace,
          project_id: project,
          group_link: { group_access: ProjectGroupLink::GUEST } }
      end

      it 'updates the max_seats_used counter' do
        expect(::Gitlab::Subscription::MaxSeatsUpdater)
          .to receive(:update).with(project).and_call_original

        expect do
          put(:update, xhr: true, params: update_params)
        end.to change { gitlab_subscription.reload.max_seats_used }.from(0).to(1)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:group_link) { create_group_link }

    before do
      Gitlab::Subscription::MaxSeatsUpdater.update(project)
    end

    it 'does not decrease the max_seats_used counter' do
      expect(::Gitlab::Subscription::MaxSeatsUpdater)
        .to receive(:update).with(project).and_call_original

      delete(:destroy, params: { id: group_link.id, namespace_id: project.namespace, project_id: project })

      expect(gitlab_subscription.reload.max_seats_used).to eq(1)
    end
  end

  def create_group_link
    result = Projects::GroupLinks::CreateService.new(project, user, link_group_access: ProjectGroupLink.default_access)
      .execute(group)

    result[:link]
  end
end
