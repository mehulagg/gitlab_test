# frozen_string_literal: true

shared_examples 'helm commands' do
  describe '#generate_script' do
    let(:helm_setup) do
      <<~EOS
         set -xeo pipefail
      EOS
    end

    it 'returns appropriate command' do
      expect(subject.generate_script.strip).to eq((helm_setup + commands).strip)
    end
  end
end

shared_examples 'rbac aware helm command' do
  describe '#rbac?' do
    subject { command.rbac? }

    context 'rbac is enabled' do
      let(:rbac) { true }

      it { is_expected.to be_truthy }
    end

    context 'rbac is not enabled' do
      let(:rbac) { false }

      it { is_expected.to be_falsey }
    end
  end

  describe '#pod_resource' do
    subject { command.pod_resource }

    context 'rbac is enabled' do
      let(:rbac) { true }

      it { is_expected.to be_an_instance_of ::Kubeclient::Resource }

      it 'generates a pod that uses the tiller serviceAccountName' do
        expect(subject.spec.serviceAccountName).to eq('tiller')
      end
    end

    context 'rbac is not enabled' do
      let(:rbac) { false }

      it { is_expected.to be_an_instance_of ::Kubeclient::Resource }

      it 'generates a pod that uses the default serviceAccountName' do
        expect(subject.spec.serviceAcccountName).to be_nil
      end
    end
  end

  describe '#config_map_resource' do
    subject { command.config_map_resource }

    let(:metadata) do
      {
        name: "values-content-configuration-#{command.name}",
        namespace: 'gitlab-managed-apps',
        labels: { name: "values-content-configuration-#{command.name}" }
      }
    end

    let(:resource) { ::Kubeclient::Resource.new(metadata: metadata, data: command.files) }

    it 'returns a KubeClient resource with config map content for the application' do
      is_expected.to eq(resource)
    end
  end
end

shared_examples 'non-initializing helm command' do
  describe '#service_account_resource' do
    subject { command.service_account_resource }

    context 'rbac is enabled' do
      let(:rbac) { true }

      it { is_expected.to be_nil }
    end

    context 'rbac is not enabled' do
      let(:rbac) { false }

      it { is_expected.to be_nil }
    end
  end

  describe '#cluster_role_binding_resource' do
    subject { command.cluster_role_binding_resource }

    context 'rbac is enabled' do
      let(:rbac) { true }

      it { is_expected.to be_nil }
    end

    context 'rbac is not enabled' do
      let(:rbac) { false }

      it { is_expected.to be_nil }
    end
  end
end
