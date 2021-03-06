# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EnvironmentEntity do
  include KubernetesHelpers

  let(:user) { create(:user) }
  let(:environment) { create(:environment) }
  let(:project) { create(:project) }

  let(:entity) do
    described_class.new(environment, request: double(current_user: user, project: project))
  end

  describe '#as_json' do
    subject { entity.as_json }

    context 'with alert' do
      let!(:environment) { create(:environment, project: project) }
      let!(:prometheus_alert) { create(:prometheus_alert, project: project, environment: environment) }
      let!(:alert) { create(:alert_management_alert, :triggered, :prometheus, project: project, environment: environment, prometheus_alert: prometheus_alert) }

      before do
        stub_licensed_features(environment_alerts: true)
      end

      it 'exposes active alert flag' do
        project.add_maintainer(user)

        expect(subject[:has_opened_alert]).to eq(true)
      end

      context 'when user does not have permission to read alert' do
        it 'does not expose active alert flag' do
          project.add_reporter(user)

          expect(subject[:has_opened_alert]).to be_nil
        end
      end

      context 'when license is insufficient' do
        before do
          stub_licensed_features(environment_alerts: false)
        end

        it 'does not expose active alert flag' do
          project.add_maintainer(user)

          expect(subject[:has_opened_alert]).to be_nil
        end
      end
    end

    context 'when deploy_boards are available' do
      before do
        stub_licensed_features(deploy_board: true)
      end

      context 'with deployment service ready' do
        before do
          allow(environment).to receive(:has_terminals?).and_return(true)
          allow(environment).to receive(:rollout_status).and_return(kube_deployment_rollout_status)
          environment.project.add_maintainer(user)
        end

        it 'exposes rollout_status' do
          expect(subject).to include(:rollout_status)
        end
      end
    end

    context 'when deploy_boards are not available' do
      before do
        allow(environment).to receive(:has_terminals?).and_return(true)
      end

      it 'does not expose rollout_status' do
        expect(subject).not_to include(:rollout_status)
      end
    end

    context 'when environment has a review app' do
      let(:project) { create(:project, :repository) }
      let(:environment) { create(:environment, :with_review_app, ref: 'development', project: project) }
      let(:protected_environment) { create(:protected_environment, name: environment.name, project: project) }

      before do
        project.repository.add_branch(user, 'development', project.commit.id)
      end

      describe '#can_stop' do
        subject { entity.as_json[:can_stop] }

        it_behaves_like 'protected environments access'
      end

      describe '#terminal_path' do
        before do
          allow(environment).to receive(:has_terminals?).and_return(true)
        end

        subject { entity.as_json.include?(:terminal_path) }

        it_behaves_like 'protected environments access', developer_access: false
      end
    end
  end
end
