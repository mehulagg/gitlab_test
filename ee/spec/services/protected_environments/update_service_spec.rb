require 'spec_helper'

describe ProtectedEnvironments::UpdateService do
  let(:project) { create(:project) }
  let(:user) { create(:user) }
  let(:master_access) { Gitlab::Access::MASTER }
  let(:developer_access) { Gitlab::Access::DEVELOPER }
  let(:protected_environment) { create(:protected_environment, project: project) }
  let(:deploy_access_level) { protected_environment.deploy_access_levels.first }

  let(:params) do
    {
      deploy_access_levels_attributes: [
        { id: deploy_access_level.id, access_level: developer_access },
        { access_level: master_access }
      ]
    }
  end

  describe '#execute' do
    subject { described_class.new(project, user, params).execute(protected_environment) }

    context 'when the user is authorized' do
      before do
        project.add_master(user)
      end

      it 'should update the requested ProtectedEnvironment' do
        subject

        expect(protected_environment.deploy_access_levels.count).to eq(2)
      end
    end

    context 'when the user is not authorized' do
      before do
        project.add_developer(user)
      end

      it 'should raise a Gitlab::AccessDeniedError' do
        expect { subject }.to raise_error(Gitlab::Access::AccessDeniedError)
      end
    end
  end
end
