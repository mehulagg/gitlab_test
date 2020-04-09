# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Unleash do
  let(:feature) { :feature }

  before do
    # We mock all calls to .enabled? to return true in order to force all
    # specs to run the feature flag gated behavior, but here we need a clean
    # behavior from the class
    allow(described_class).to receive(:enabled?).and_call_original
  end

  context 'unleash client is configured' do
    let(:unleash_client) { instance_double(Unleash::Client) }

    before do
      allow(Rails.application.config).to receive(:unleash).and_return(unleash_client)
    end

    context 'an enabled feature' do
      before do
        allow(unleash_client).to receive(:enabled?).and_return(true)
      end

      it 'is indicated to be enabled' do
        expect(Gitlab::Unleash.enabled?(feature)).to be_truthy
        expect(Gitlab::Unleash.enabled?(feature, default_enabled: false)).to be_truthy
        expect(Gitlab::Unleash.enabled?(feature, default_enabled: true)).to be_truthy
      end

      it 'falls back to defaults when gitlab_unleash_client is disabled' do
        stub_feature_flags(gitlab_unleash_client: false)
        expect(Gitlab::Unleash.enabled?(feature)).to be_falsey
        expect(Gitlab::Unleash.enabled?(feature, default_enabled: false)).to be_falsey
        expect(Gitlab::Unleash.enabled?(feature, default_enabled: true)).to be_truthy
      end
    end

    context 'a feature enabled for a specific user' do
      let(:enabled_user) { "bob" }
      let(:enabled_context) { Unleash::Context.new(user_id: enabled_user) }

      let(:disabled_user) { "ann" }
      let(:disabled_context) { Unleash::Context.new(user_id: disabled_user) }

      before do
        allow(unleash_client).to receive(:enabled?) do |feature, context, default|
          context.user_id == enabled_user
        end
      end

      it 'is indicated to be disabled for everyone else' do
        expect(Gitlab::Unleash.enabled?(feature, context: disabled_context)).to be_falsey
        expect(Gitlab::Unleash.enabled?(feature, context: disabled_context, default_enabled: false)).to be_falsey
        expect(Gitlab::Unleash.enabled?(feature, context: disabled_context, default_enabled: true)).to be_falsey
      end

      it 'is indicated to be enabled for that user' do
        expect(Gitlab::Unleash.enabled?(feature, context: enabled_context)).to be_truthy
        expect(Gitlab::Unleash.enabled?(feature, context: enabled_context, default_enabled: false)).to be_truthy
        expect(Gitlab::Unleash.enabled?(feature, context: enabled_context, default_enabled: true)).to be_truthy
      end

      it 'falls back to defaults when gitlab_unleash_client is disabled' do
        stub_feature_flags(gitlab_unleash_client: false)
        expect(Gitlab::Unleash.enabled?(feature, context: disabled_context)).to be_falsey
        expect(Gitlab::Unleash.enabled?(feature, context: disabled_context, default_enabled: false)).to be_falsey
        expect(Gitlab::Unleash.enabled?(feature, context: disabled_context, default_enabled: true)).to be_truthy

        expect(Gitlab::Unleash.enabled?(feature, context: enabled_context)).to be_falsey
        expect(Gitlab::Unleash.enabled?(feature, context: enabled_context, default_enabled: false)).to be_falsey
        expect(Gitlab::Unleash.enabled?(feature, context: enabled_context, default_enabled: true)).to be_truthy
      end
    end

    context 'a disabled feature' do
      before do
        allow(unleash_client).to receive(:enabled?).and_return(false)
      end

      it 'is indicated to be disabled' do
        expect(Gitlab::Unleash.enabled?(feature)).to be_falsey
        expect(Gitlab::Unleash.enabled?(feature, default_enabled: false)).to be_falsey
        expect(Gitlab::Unleash.enabled?(feature, default_enabled: true)).to be_falsey
      end

      it 'falls back to defaults when gitlab_unleash_client is disabled' do
        stub_feature_flags(gitlab_unleash_client: false)
        expect(Gitlab::Unleash.enabled?(feature)).to be_falsey
        expect(Gitlab::Unleash.enabled?(feature, default_enabled: false)).to be_falsey
        expect(Gitlab::Unleash.enabled?(feature, default_enabled: true)).to be_truthy
      end
    end

    context 'a feature that does not exist' do
      before do
        allow(unleash_client).to receive(:enabled?) { |feature, context, default| default }
      end

      it 'falls back to defaults' do
        expect(Gitlab::Unleash.enabled?(feature)).to be_falsey
        expect(Gitlab::Unleash.enabled?(feature, default_enabled: false)).to be_falsey
        expect(Gitlab::Unleash.enabled?(feature, default_enabled: true)).to be_truthy
      end

      it 'falls back to defaults when gitlab_unleash_client is disabled' do
        stub_feature_flags(gitlab_unleash_client: false)
        expect(Gitlab::Unleash.enabled?(feature)).to be_falsey
        expect(Gitlab::Unleash.enabled?(feature, default_enabled: false)).to be_falsey
        expect(Gitlab::Unleash.enabled?(feature, default_enabled: true)).to be_truthy
      end
    end
  end

  context 'unleash client is not configured' do
    before do
      allow(Rails.application.config).to receive(:unleash).and_return(nil)
    end

    it 'falls back to defaults' do
      expect(Gitlab::Unleash.enabled?(feature)).to be_falsey
      expect(Gitlab::Unleash.enabled?(feature, default_enabled: false)).to be_falsey
      expect(Gitlab::Unleash.enabled?(feature, default_enabled: true)).to be_truthy
    end

    it 'falls back to defaults when gitlab_unleash_client is disabled' do
      stub_feature_flags(gitlab_unleash_client: false)
      expect(Gitlab::Unleash.enabled?(feature)).to be_falsey
      expect(Gitlab::Unleash.enabled?(feature, default_enabled: false)).to be_falsey
      expect(Gitlab::Unleash.enabled?(feature, default_enabled: true)).to be_truthy
    end
  end
end
