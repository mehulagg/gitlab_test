# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Kubernetes::Helm::InitCommand do
  subject(:init_command) { described_class.new(name: application.name, files: files, rbac: rbac) }

  let(:application) { create(:clusters_applications_helm) }
  let(:rbac) { false }
  let(:files) { {} }

  it_behaves_like 'helm commands' do
    let(:commands) do
      <<~EOS
      helm init --tiller-tls --tiller-tls-verify --tls-ca-cert /data/helm/helm/config/ca.pem --tiller-tls-cert /data/helm/helm/config/cert.pem --tiller-tls-key /data/helm/helm/config/key.pem
      EOS
    end
  end

  context 'on a rbac-enabled cluster' do
    let(:rbac) { true }

    it_behaves_like 'helm commands' do
      let(:commands) do
        <<~EOS
        helm init --tiller-tls --tiller-tls-verify --tls-ca-cert /data/helm/helm/config/ca.pem --tiller-tls-cert /data/helm/helm/config/cert.pem --tiller-tls-key /data/helm/helm/config/key.pem --service-account tiller
        EOS
      end
    end
  end

  describe '#service_account_resource' do
    subject { init_command.service_account_resource }

    let(:resource) do
      Kubeclient::Resource.new(metadata: { name: 'tiller', namespace: 'gitlab-managed-apps' })
    end

    context 'rbac is enabled' do
      let(:rbac) { true }

      it 'generates a Kubeclient resource for the tiller ServiceAccount' do
        is_expected.to eq(resource)
      end
    end

    context 'rbac is not enabled' do
      let(:rbac) { false }

      it 'generates nothing' do
        is_expected.to be_nil
      end
    end
  end

  describe '#cluster_role_binding_resource' do
    subject { init_command.cluster_role_binding_resource }

    let(:resource) do
      Kubeclient::Resource.new(
        metadata: { name: 'tiller-admin' },
        roleRef: { apiGroup: 'rbac.authorization.k8s.io', kind: 'ClusterRole', name: 'cluster-admin' },
        subjects: [{ kind: 'ServiceAccount', name: 'tiller', namespace: 'gitlab-managed-apps' }]
      )
    end

    context 'rbac is enabled' do
      let(:rbac) { true }

      it 'generates a Kubeclient resource for the ClusterRoleBinding for tiller' do
        is_expected.to eq(resource)
      end
    end

    context 'rbac is not enabled' do
      let(:rbac) { false }

      it 'generates nothing' do
        is_expected.to be_nil
      end
    end
  end

  it_behaves_like 'rbac aware helm command' do
    let(:command) { init_command }
  end
end
