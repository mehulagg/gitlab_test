# frozen_string_literal: true

RSpec.shared_examples 'resource with requirement permissions' do
  subject { described_class.new(current_user, resource) }

  context 'when requirements feature is enabled' do
    before do
      stub_licensed_features(requirements: true)
    end

    context 'with admin' do
      let(:current_user) { admin }

      it { is_expected.to be_allowed(:read_requirement, :create_requirement, :admin_requirement, :update_requirement, :destroy_requirement) }
    end

    context 'with owner' do
      let(:current_user) { owner }

      it { is_expected.to be_allowed(:read_requirement, :create_requirement, :admin_requirement, :update_requirement, :destroy_requirement) }
    end

    context 'with reporter' do
      let(:current_user) { reporter }

      it { is_expected.to be_allowed(:read_requirement, :create_requirement, :admin_requirement, :update_requirement) }
      it { is_expected.to be_disallowed(:destroy_requirement) }
    end

    context 'with guest' do
      let(:current_user) { guest }

      it { is_expected.to be_allowed(:read_requirement) }
      it { is_expected.to be_disallowed(:create_requirement, :admin_requirement, :update_requirement, :destroy_requirement) }
    end

    context 'with non member' do
      let(:current_user) { create(:user) }

      it { is_expected.to be_allowed(:read_requirement) }
      it { is_expected.to be_disallowed(:create_requirement, :admin_requirement, :update_requirement, :destroy_requirement) }

      context 'with private resource parent' do
        before do
          parent = resource.is_a?(Project) ? resource : resource.resource_parent
          parent.update!(visibility_level: Gitlab::VisibilityLevel::PRIVATE)
        end

        it { is_expected.to be_disallowed(:read_requirement, :create_requirement, :admin_requirement, :update_requirement, :destroy_requirement) }
      end
    end
  end

  context 'when requirements feature is disabled' do
    before do
      stub_licensed_features(requirements: false)
    end

    context 'with owner' do
      let(:current_user) { owner }

      it { is_expected.to be_disallowed(:read_requirement, :create_requirement, :admin_requirement, :update_requirement, :destroy_requirement) }
    end
  end
end
