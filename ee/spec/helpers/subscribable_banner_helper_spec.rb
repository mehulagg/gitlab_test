# frozen_string_literal: true

require 'spec_helper'

describe SubscribableBannerHelper do
  describe '#gitlab_subscription_or_license' do
    subject { helper.gitlab_subscription_or_license }

    context 'when feature flag is enabled' do
      let(:license) { double(:license) }

      before do
        stub_feature_flags(subscribable_banner: true)
      end

      context 'when instance variable true' do
        before do
          assign(:display_subscription_banner, true)
        end

        context 'when should_check_namespace_plan is true' do
          before do
            allow(::Gitlab::CurrentSettings).to receive(:should_check_namespace_plan?).and_return(true)
          end

          let(:subscription) { double(:subscription) }

          it 'returns a decorated subscription' do
            expect(helper).to receive(:decorated_subscription).and_return(subscription)
            expect(subject).to eq(subscription)
          end
        end

        context 'when should_check_namespace_plan is false' do
          before do
            allow(::Gitlab::CurrentSettings).to receive(:should_check_namespace_plan?).and_return(false)
          end

          it 'returns the current license' do
            expect(License).to receive(:current).and_return(license)
            expect(subject).to eq(license)
          end
        end
      end

      context 'when instance variable false' do
        before do
          assign(:display_subscription_banner, false)
          allow(::Gitlab::CurrentSettings).to receive(:should_check_namespace_plan?).and_return(true)
        end

        it 'returns the current license' do
          expect(License).to receive(:current).and_return(license)
          expect(subject).to eq(license)
        end
      end
    end
  end

  describe '#gitlab_subscription_message_or_license_message' do
    subject { helper.gitlab_subscription_message_or_license_message }

    let(:message) { double(:message) }

    context 'when feature flag is enabled' do
      before do
        stub_feature_flags(subscribable_banner: true)
      end

      context 'when instance variable true' do
        before do
          assign(:display_subscription_banner, true)
        end

        context 'when should_check_namespace_plan is true' do
          before do
            allow(::Gitlab::CurrentSettings).to receive(:should_check_namespace_plan?).and_return(true)
          end

          let(:subscription) { double(:subscription) }

          it 'returns the subscription message' do
            expect(helper).to receive(:subscription_message).and_return(message)
            expect(subject).to eq(message)
          end
        end

        context 'when should_check_namespace_plan is false' do
          before do
            allow(::Gitlab::CurrentSettings).to receive(:should_check_namespace_plan?).and_return(false)
          end

          it 'returns the license message' do
            expect(helper).to receive(:license_message).and_return(message)
            expect(subject).to eq(message)
          end
        end
      end

      context 'when instance variable false' do
        before do
          assign(:display_subscription_banner, false)
          allow(::Gitlab::CurrentSettings).to receive(:should_check_namespace_plan?).and_return(true)
        end

        it 'returns the license message' do
          expect(helper).to receive(:license_message).and_return(message)
          expect(subject).to eq(message)
        end
      end
    end
  end

  describe '#display_subscription_banner!' do
    it 'sets @display_subscription_banner to true' do
      expect(helper.instance_variable_get(:@display_subscription_banner)).to be nil

      helper.display_subscription_banner!

      expect(helper.instance_variable_get(:@display_subscription_banner)).to be true
    end
  end
end
