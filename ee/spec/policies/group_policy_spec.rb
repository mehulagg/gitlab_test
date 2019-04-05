require 'spec_helper'

describe GroupPolicy do
  include_context 'GroupPolicy context'

  context 'when epics feature is disabled' do
    let(:current_user) { owner }

    it { is_expected.to be_disallowed(:read_epic, :create_epic, :admin_epic, :destroy_epic) }
  end

  context 'when epics feature is enabled' do
    before do
      stub_licensed_features(epics: true)
    end

    let(:current_user) { owner }

    it { is_expected.to be_allowed(:read_epic, :create_epic, :admin_epic, :destroy_epic) }
  end

  context 'when contribution analytics is available' do
    let(:current_user) { developer }

    before do
      stub_licensed_features(contribution_analytics: true)
    end

    it { is_expected.to be_allowed(:read_group_contribution_analytics) }
  end

  context 'when contribution analytics is not available' do
    let(:current_user) { developer }

    before do
      stub_licensed_features(contribution_analytics: false)
    end

    it { is_expected.not_to be_allowed(:read_group_contribution_analytics) }
  end

  describe 'per group SAML' do
    let(:current_user) { maintainer }

    it { is_expected.to be_disallowed(:admin_group_saml) }

    context 'owner' do
      let(:current_user) { owner }

      it { is_expected.to be_allowed(:admin_group_saml) }
    end

    context 'admin' do
      let(:current_user) { admin }

      it { is_expected.to be_allowed(:admin_group_saml) }
    end
  end

  context 'when LDAP sync is not enabled' do
    context 'owner' do
      let(:current_user) { owner }

      it { is_expected.to be_disallowed(:override_group_member) }
      it { is_expected.to be_allowed(:admin_ldap_group_links) }

      context 'does not allow group owners to manage ldap' do
        before do
          stub_application_setting(allow_group_owners_to_manage_ldap: false)
        end

        it { is_expected.to be_disallowed(:admin_ldap_group_links) }
      end
    end

    context 'admin' do
      let(:current_user) { admin }

      it { is_expected.to be_disallowed(:override_group_member) }
      it { is_expected.to be_allowed(:admin_ldap_group_links) }
    end
  end

  context 'when LDAP sync is enabled' do
    before do
      allow(group).to receive(:ldap_synced?).and_return(true)
    end

    context 'with no user' do
      let(:current_user) { nil }

      it { is_expected.to be_disallowed(:override_group_member) }
      it { is_expected.to be_disallowed(:admin_ldap_group_links) }
    end

    context 'guests' do
      let(:current_user) { guest }

      it { is_expected.to be_disallowed(:override_group_member) }
      it { is_expected.to be_disallowed(:admin_ldap_group_links) }
    end

    context 'reporter' do
      let(:current_user) { reporter }

      it { is_expected.to be_disallowed(:override_group_member) }
      it { is_expected.to be_disallowed(:admin_ldap_group_links) }
    end

    context 'developer' do
      let(:current_user) { developer }

      it { is_expected.to be_disallowed(:override_group_member) }
      it { is_expected.to be_disallowed(:admin_ldap_group_links) }
    end

    context 'maintainer' do
      let(:current_user) { maintainer }

      it { is_expected.to be_disallowed(:override_group_member) }
      it { is_expected.to be_disallowed(:admin_ldap_group_links) }
    end

    context 'owner' do
      let(:current_user) { owner }

      context 'allow group owners to manage ldap' do
        it { is_expected.to be_allowed(:override_group_member) }
      end

      context 'does not allow group owners to manage ldap' do
        before do
          stub_application_setting(allow_group_owners_to_manage_ldap: false)
        end

        it { is_expected.to be_disallowed(:override_group_member) }
        it { is_expected.to be_disallowed(:admin_ldap_group_links) }
      end
    end

    context 'admin' do
      let(:current_user) { admin }

      it { is_expected.to be_allowed(:override_group_member) }
      it { is_expected.to be_allowed(:admin_ldap_group_links) }
    end
  end

  context "create_projects" do
    context 'project_creation_level enabled' do
      before do
        stub_licensed_features(project_creation_level: true)
      end

      context 'when group has no project creation level set' do
        let(:group) { create(:group, project_creation_level: nil) }

        context 'reporter' do
          let(:current_user) { reporter }

          it { is_expected.to be_disallowed(:create_projects) }
        end

        context 'developer' do
          let(:current_user) { developer }

          it { is_expected.to be_allowed(:create_projects) }
        end

        context 'maintainer' do
          let(:current_user) { maintainer }

          it { is_expected.to be_allowed(:create_projects) }
        end

        context 'owner' do
          let(:current_user) { owner }

          it { is_expected.to be_allowed(:create_projects) }
        end
      end

      context 'when group has project creation level set to no one' do
        let(:group) { create(:group, project_creation_level: ::EE::Gitlab::Access::NO_ONE_PROJECT_ACCESS) }

        context 'reporter' do
          let(:current_user) { reporter }

          it { is_expected.to be_disallowed(:create_projects) }
        end

        context 'developer' do
          let(:current_user) { developer }

          it { is_expected.to be_disallowed(:create_projects) }
        end

        context 'maintainer' do
          let(:current_user) { maintainer }

          it { is_expected.to be_disallowed(:create_projects) }
        end

        context 'owner' do
          let(:current_user) { owner }

          it { is_expected.to be_disallowed(:create_projects) }
        end
      end

      context 'when group has project creation level set to maintainer only' do
        let(:group) { create(:group, project_creation_level: ::EE::Gitlab::Access::MAINTAINER_PROJECT_ACCESS) }

        context 'reporter' do
          let(:current_user) { reporter }

          it { is_expected.to be_disallowed(:create_projects) }
        end

        context 'developer' do
          let(:current_user) { developer }

          it { is_expected.to be_disallowed(:create_projects) }
        end

        context 'maintainer' do
          let(:current_user) { maintainer }

          it { is_expected.to be_allowed(:create_projects) }
        end

        context 'owner' do
          let(:current_user) { owner }

          it { is_expected.to be_allowed(:create_projects) }
        end
      end

      context 'when group has project creation level set to developers + maintainer' do
        let(:group) { create(:group, project_creation_level: ::EE::Gitlab::Access::DEVELOPER_MAINTAINER_PROJECT_ACCESS) }

        context 'reporter' do
          let(:current_user) { reporter }

          it { is_expected.to be_disallowed(:create_projects) }
        end

        context 'developer' do
          let(:current_user) { developer }

          it { is_expected.to be_allowed(:create_projects) }
        end

        context 'maintainer' do
          let(:current_user) { maintainer }

          it { is_expected.to be_allowed(:create_projects) }
        end

        context 'owner' do
          let(:current_user) { owner }

          it { is_expected.to be_allowed(:create_projects) }
        end
      end
    end

    context 'project_creation_level disabled' do
      before do
        stub_licensed_features(project_creation_level: false)
      end

      context 'when group has no project creation level set' do
        let(:group) { create(:group, project_creation_level: nil) }

        context 'reporter' do
          let(:current_user) { reporter }

          it { is_expected.to be_disallowed(:create_projects) }
        end

        context 'developer' do
          let(:current_user) { developer }

          it { is_expected.to be_disallowed(:create_projects) }
        end

        context 'maintainer' do
          let(:current_user) { maintainer }

          it { is_expected.to be_allowed(:create_projects) }
        end

        context 'owner' do
          let(:current_user) { owner }

          it { is_expected.to be_allowed(:create_projects) }
        end
      end

      context 'when group has project creation level set to no one' do
        let(:group) { create(:group, project_creation_level: ::EE::Gitlab::Access::NO_ONE_PROJECT_ACCESS) }

        context 'reporter' do
          let(:current_user) { reporter }

          it { is_expected.to be_disallowed(:create_projects) }
        end

        context 'developer' do
          let(:current_user) { developer }

          it { is_expected.to be_disallowed(:create_projects) }
        end

        context 'maintainer' do
          let(:current_user) { maintainer }

          it { is_expected.to be_allowed(:create_projects) }
        end

        context 'owner' do
          let(:current_user) { owner }

          it { is_expected.to be_allowed(:create_projects) }
        end
      end

      context 'when group has project creation level set to maintainer only' do
        let(:group) { create(:group, project_creation_level: ::EE::Gitlab::Access::MAINTAINER_PROJECT_ACCESS) }

        context 'reporter' do
          let(:current_user) { reporter }

          it { is_expected.to be_disallowed(:create_projects) }
        end

        context 'developer' do
          let(:current_user) { developer }

          it { is_expected.to be_disallowed(:create_projects) }
        end

        context 'maintainer' do
          let(:current_user) { maintainer }

          it { is_expected.to be_allowed(:create_projects) }
        end

        context 'owner' do
          let(:current_user) { owner }

          it { is_expected.to be_allowed(:create_projects) }
        end
      end

      context 'when group has project creation level set to developers + maintainer' do
        let(:group) { create(:group, project_creation_level: ::EE::Gitlab::Access::DEVELOPER_MAINTAINER_PROJECT_ACCESS) }

        context 'reporter' do
          let(:current_user) { reporter }

          it { is_expected.to be_disallowed(:create_projects) }
        end

        context 'developer' do
          let(:current_user) { developer }

          it { is_expected.to be_disallowed(:create_projects) }
        end

        context 'maintainer' do
          let(:current_user) { maintainer }

          it { is_expected.to be_allowed(:create_projects) }
        end

        context 'owner' do
          let(:current_user) { owner }

          it { is_expected.to be_allowed(:create_projects) }
        end
      end
    end
  end

  describe 'read_group_security_dashboard' do
    before do
      stub_licensed_features(security_dashboard: true)
    end

    context 'with admin' do
      let(:current_user) { admin }

      it { is_expected.to be_allowed(:read_group_security_dashboard) }
    end

    context 'with owner' do
      let(:current_user) { owner }

      it { is_expected.to be_allowed(:read_group_security_dashboard) }
    end

    context 'with maintainer' do
      let(:current_user) { maintainer }

      it { is_expected.to be_allowed(:read_group_security_dashboard) }
    end

    context 'with developer' do
      let(:current_user) { developer }

      it { is_expected.to be_allowed(:read_group_security_dashboard) }

      context 'when security dashboard features is not available' do
        before do
          stub_licensed_features(security_dashboard: false)
        end

        it { is_expected.to be_disallowed(:read_group_security_dashboard) }
      end
    end

    context 'with reporter' do
      let(:current_user) { reporter }

      it { is_expected.to be_disallowed(:read_group_security_dashboard) }
    end

    context 'with guest' do
      let(:current_user) { guest }

      it { is_expected.to be_disallowed(:read_group_security_dashboard) }
    end

    context 'with non member' do
      let(:current_user) { create(:user) }

      it { is_expected.to be_disallowed(:read_group_security_dashboard) }
    end

    context 'with anonymous' do
      let(:current_user) { nil }

      it { is_expected.to be_disallowed(:read_group_security_dashboard) }
    end
  end

  describe 'private nested group use the highest access level from the group and inherited permissions', :nested_groups do
    let(:nested_group) { create(:group, :private, parent: group) }

    before do
      nested_group.add_guest(guest)
      nested_group.add_guest(reporter)
      nested_group.add_guest(developer)
      nested_group.add_guest(maintainer)

      group.owners.destroy_all # rubocop: disable DestroyAll

      group.add_guest(owner)
      nested_group.add_owner(owner)
    end

    subject { described_class.new(current_user, nested_group) }

    context 'auditor' do
      let(:current_user) { create(:user, :auditor) }

      it do
        expect_allowed(:read_group)
        expect_disallowed(:upload_file)
        expect_disallowed(*reporter_permissions)
        expect_disallowed(*developer_permissions)
        expect_disallowed(*maintainer_permissions)
        expect_disallowed(*owner_permissions)
      end
    end
  end

  it_behaves_like 'ee clusterable policies' do
    let(:clusterable) { create(:group) }
    let(:cluster) do
      create(:cluster,
             :provided_by_gcp,
             :group,
             groups: [clusterable])
    end
  end
end
