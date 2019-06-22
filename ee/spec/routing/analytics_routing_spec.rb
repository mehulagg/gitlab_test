# frozen_string_literal: true

require 'spec_helper'

describe 'Analytics', :routing do
  include RSpec::Rails::RequestExampleGroup

  it "redirects `/-/analytics` to `/-/analytics/productivity_analytics`" do
    expect(get('/-/analytics')).to redirect_to('/-/analytics/productivity_analytics')
  end

  it 'route_not_found if :analytics feature is disabled' do
    stub_feature_flags(analytics: false)

    expect(get: '/-/analytics').to route_to(controller: 'application', action: 'route_not_found', unmatched_route: '-/analytics')
  end
end
