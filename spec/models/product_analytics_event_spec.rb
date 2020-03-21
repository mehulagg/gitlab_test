# frozen_string_literal: true
require 'spec_helper'

RSpec.describe ProductAnalyticsEvent, type: :model do
  it 'responds to :get_some' do
    expect(ProductAnalyticsEvent).to respond_to(:get_some)
  end
  it 'responds to :by_day_and_graph' do
    expect(ProductAnalyticsEvent).to respond_to(:by_day_and_graph)
  end
  it 'responds to :by_graph' do
    expect(ProductAnalyticsEvent).to respond_to(:by_graph)
  end
  it 'responds to :count' do
    expect(ProductAnalyticsEvent).to respond_to(:count)
  end
end
