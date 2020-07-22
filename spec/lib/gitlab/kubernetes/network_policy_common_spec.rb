# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Kubernetes::NetworkPolicyCommon do
  let(:policy) do
    described_class.new(
      name,
      namespace,
      resource_version,
      selector
    )
  end
  let(:partial_class_name) { described_class.name.split('::').last }
  let(:resource_version) { '101' }
  let(:name) { 'example-name' }
  let(:namespace) { 'example-namespace' }
  let(:selector) { { matchLabels: { role: 'db' } } }

  describe '#generate' do
    let(:resource) do
      ::Kubeclient::Resource.new(
        kind: partial_class_name,
        metadata: { name: name, namespace: namespace, resourceVersion: resource_version },
        spec: { selector: selector }
      )
    end

    subject { policy.generate }

    it 'raises not implemented error' do
      expect { subject }.to raise_error NotImplementedError
    end

    context 'with spec method implemented' do
      before { allow(policy).to receive(:spec).and_return({selector: selector}) }

      it { is_expected.to eq(resource) }

      context 'with api_version class method implement' do
        let(:api_version) { 'host.io/v1' }
        let(:resource) do
          ::Kubeclient::Resource.new(
            kind: partial_class_name,
            apiVersion: api_version,
            metadata: { name: name, namespace: namespace, resourceVersion: resource_version },
            spec: { selector: selector }
          )
        end

        before { allow(Gitlab::Kubernetes::NetworkPolicyCommon).to receive(:api_version).and_return(api_version) }

        it { is_expected.to eq(resource) }
      end
    end
    
  end

  describe '#as_json' do
    let(:json_policy) do
      {
        name: name,
        namespace: namespace,
        resource_version: resource_version,
        creation_timestamp: nil,
        manifest: YAML.dump(
          {
            metadata: { name: name, namespace: namespace, resourceVersion: resource_version },
            spec: { selector: selector }
          }.deep_stringify_keys
        ),
        is_autodevops: false,
        is_enabled: true,
        is_standard: false,
      }
    end

    subject { policy.as_json }

    it 'raises not implemented error' do
      expect { subject }.to raise_error NotImplementedError
    end

    context 'with spec method implemented' do
      before { allow(policy).to receive(:spec).and_return({selector: selector}) }
  
      it { is_expected.to eq(json_policy) }
    end
  end

  describe '#autodevops?' do
    subject { policy.autodevops? }

    let(:chart) { nil }
    let(:policy) do
      described_class.new(
        name,
        namespace,
        resource_version,
        selector,
        { chart: chart }
      )
    end

    it { is_expected.to be false }

    context 'with non-autodevops chart' do
      let(:chart) { 'foo' }

      it { is_expected.to be false }
    end

    context 'with autodevops chart' do
      let(:chart) { 'auto-deploy-app-0.6.0' }

      it { is_expected.to be true }
    end
  end

  describe '#enabled?' do
    subject { policy.enabled? }

    let(:selector) { nil }
    let(:policy) do
      described_class.new(
        name,
        namespace,
        resource_version,
        selector
      )
    end

    it { is_expected.to be true }

    context 'with empty selector' do
      let(:selector) { {} }

      it { is_expected.to be true }
    end

    context 'with nil matchLabels in selector' do
      let(:selector) { { matchLabels: nil } }

      it { is_expected.to be true }
    end

    context 'with empty matchLabels in selector' do
      let(:selector) { { matchLabels: {} } }

      it { is_expected.to be true }
    end

    context 'with disabled_by label in matchLabels in selector' do
      let(:selector) do
        { matchLabels: { Gitlab::Kubernetes::NetworkPolicyCommon::DISABLED_BY_LABEL => 'gitlab' } }
      end

      it { is_expected.to be false }
    end
  end

  describe '#enable' do
    subject { policy.enabled? }

    let(:selector) { nil }
    let(:policy) do
      described_class.new(
        name,
        namespace,
        resource_version,
        selector
      )
    end

    before do
      policy.enable
    end

    it { is_expected.to be true }

    context 'with empty selector' do
      let(:selector) { {} }

      it { is_expected.to be true }
    end

    context 'with nil matchLabels in selector' do
      let(:selector) { { matchLabels: nil } }

      it { is_expected.to be true }
    end

    context 'with empty matchLabels in selector' do
      let(:selector) { { matchLabels: {} } }

      it { is_expected.to be true }
    end

    context 'with disabled_by label in matchLabels in selector' do
      let(:selector) do
        { matchLabels: { Gitlab::Kubernetes::NetworkPolicyCommon::DISABLED_BY_LABEL => 'gitlab' } }
      end

      it { is_expected.to be true }
    end
  end

  describe '#disable' do
    subject { policy.enabled? }

    let(:selector) { nil }
    let(:policy) do
      described_class.new(
        name,
        namespace,
        resource_version,
        selector
      )
    end

    before do
      policy.disable
    end

    it { is_expected.to be false }

    context 'with empty selector' do
      let(:selector) { {} }

      it { is_expected.to be false }
    end

    context 'with nil matchLabels in selector' do
      let(:selector) { { matchLabels: nil } }

      it { is_expected.to be false }
    end

    context 'with empty matchLabels in selector' do
      let(:selector) { { matchLabels: {} } }

      it { is_expected.to be false }
    end

    context 'with disabled_by label in matchLabels in selector' do
      let(:selector) do
        { matchLabels: { Gitlab::Kubernetes::NetworkPolicyCommon::DISABLED_BY_LABEL => 'gitlab' } }
      end

      it { is_expected.to be false }
    end
  end

  define '#standard?' do
    subject { policy.standard? }

    it { is_expected.to be false }

    context 'with NetworkPolicy class' do
      before {allow(policy).to receive(:is_a?).and_return(true)}

      it { is_expected.to be true }
    end
  end
end
