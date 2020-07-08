# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'ProductAnalytics::CollectorApp throttle' do
  include RackAttackSpecHelpers

  let(:request_limit) { 100 }

  include_context 'rack attack cache store'

  before do
    allow(ProductAnalyticsEvent).to receive(:create).and_return(true)
  end

  context 'per ip address' do
    let(:params) do
      {
        aid: rand(99),
        eid: SecureRandom.uuid
      }
    end

    it 'throttles the endpoint' do
      # Allow requests under the rate limit.
      request_limit.times do
        expect_ok { get '/-/collector/i', params: params }
      end

      # Reject request over the limit
      expect_rejection { get '/-/collector/i', params: params }

      # Allow request from different IP
      random_next_ip

      expect_ok { get '/-/collector/i', params: params }
    end
  end

  context 'per application id' do
    let(:params) do
      {
        aid: 101,
        eid: SecureRandom.uuid,
      }
    end

    it 'throttles the endpoint' do
      # Allow requests under the rate limit.
      request_limit.times do
        expect_ok { get '/-/collector/i', params: params }
      end

      # Ensure its not related to ip address
      random_next_ip

      # Reject request over the limit
      expect_rejection { get '/-/collector/i', params: params }

      # But allows request for different aid
      expect_ok { get '/-/collector/i', params: params.merge(aid: 102) }
    end
  end

  def random_next_ip
    expect_next_instance_of(Rack::Attack::Request) do |instance|
      expect(instance).to receive(:ip).at_least(:once).and_return(FFaker::Internet.ip_v4_address)
    end
  end
end
