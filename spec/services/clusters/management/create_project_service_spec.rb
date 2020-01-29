# frozen_string_literal: true

require 'spec_helper'

describe Clusters::Management::CreateProjectService do
  let(:cluster) { create(:cluster, :project) }
  let(:current_user) { create(:user) }

  subject { described_class.new(cluster, current_user: current_user).execute }

  shared_examples 'management project is not required' do
    it 'does not create a project' do
      expect { subject }.not_to change(cluster, :management_project)
    end
  end

  context ':auto_create_cluster_management_project feature flag is disabled' do
    before do
      stub_feature_flags(auto_create_cluster_management_project: false)
    end

    include_examples 'management project is not required'
  end

  context 'cluster already has a management project' do
    let(:cluster) { create(:cluster, :management_project) }

    include_examples 'management project is not required'
  end

  shared_examples 'creates a management project' do
    let(:project_params) do
      {
        name: "#{cluster.name} Cluster Management",
        description: 'This project is automatically generated and will be used to manage your Kubernetes cluster. [More information](/help/user/clusters/management_project)',
        namespace_id: namespace&.id,
        visibility_level: Gitlab::VisibilityLevel::PRIVATE
      }
    end

    it 'creates a management project' do
      expect(Projects::CreateService).to receive(:new)
        .with(current_user, project_params)
        .and_call_original

      subject

      management_project = cluster.management_project

      expect(management_project).to be_present
      expect(management_project).to be_private
      expect(management_project.name).to eq "#{cluster.name} Cluster Management"
      expect(management_project.namespace).to eq namespace
    end
  end

  context 'project cluster' do
    let(:cluster) { create(:cluster, projects: [project]) }
    let(:project) { create(:project, namespace: current_user.namespace) }
    let(:namespace) { project.namespace }

    include_examples 'creates a management project'

    context 'management project members' do
      let(:guest_user) { create(:user) }
      let(:developer_user) { create(:user) }
      let(:maintainer_user) { create(:user) }
      let(:inactive_maintainer_user) { create(:user, state: :blocked) }

      let(:expected_maintainers) { [maintainer_user, project.owner] }

      before do
        project.add_user(guest_user, Gitlab::Access::GUEST)
        project.add_user(developer_user, Gitlab::Access::DEVELOPER)
        project.add_users([maintainer_user, inactive_maintainer_user], Gitlab::Access::MAINTAINER)
      end

      it 'adds existing project maintainers to the new project' do
        subject

        management_project = cluster.management_project

        expect(management_project.users).to match_array(expected_maintainers)
        expect(management_project.members.maintainers.map(&:user)).to match_array(expected_maintainers)
      end
    end
  end

  context 'group cluster' do
    let(:cluster) { create(:cluster, :group, user: current_user) }
    let(:namespace) { cluster.group }

    before do
      namespace.add_user(current_user, Gitlab::Access::MAINTAINER)
    end

    include_examples 'creates a management project'
  end

  context 'instance cluster' do
    let(:cluster) { create(:cluster, :instance, user: current_user) }

    context 'instance administration project is present' do
      let(:namespace) { create(:group) }

      before do
        stub_application_setting(instance_administrators_group: namespace)

        namespace.add_user(current_user, Gitlab::Access::MAINTAINER)
      end

      include_examples 'creates a management project'
    end

    context 'instance administration project is not present' do
      let(:namespace) { current_user.namespace }

      include_examples 'creates a management project'
    end
  end

  describe 'error handling' do
    let(:project) { cluster.project }

    before do
      allow(Projects::CreateService).to receive(:new)
        .and_return(double(execute: project))
    end

    context 'project is invalid' do
      let(:errors) { double(full_messages: ["Error message"]) }
      let(:project) { instance_double(Project, errors: errors) }

      it { expect { subject }.to raise_error(described_class::CreateError, /Failed to create project/) }
    end

    context 'members are invalid' do
      let(:errors) { double(full_messages: ["Error message"]) }
      let(:invalid_member) { instance_double(ProjectMember, errors: errors) }

      before do
        allow(project).to receive(:add_users).and_return([invalid_member])
      end

      it { expect { subject }.to raise_error(described_class::CreateError, /Failed to add members to project/) }
    end

    context 'cluster is invalid' do
      before do
        allow(cluster).to receive(:update).and_return(false)
      end

      it { expect { subject }.to raise_error(described_class::CreateError, /Failed to update cluster/) }
    end

    context 'unknown cluster type' do
      before do
        allow(cluster).to receive(:cluster_type).and_return("unknown_type")
      end

      it { expect { subject }.to raise_error(NotImplementedError) }
    end
  end
end
