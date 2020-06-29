# frozen_string_literal: true
require 'spec_helper'

RSpec.describe ProductAnalyticsEvent, type: :model do
  it { expect(described_class).to respond_to(:order_by_time) }
  it { expect(described_class).to respond_to(:count_by_graph) }
  it { expect(described_class).to respond_to(:count_by_day_and_graph) }

  describe '.by_project' do
    let_it_be(:event_1) { create(:product_analytics_event) }
    let_it_be(:event_2) { create(:product_analytics_event) }

    it { expect(described_class.by_project(event_id.project_id).to_json).to eq([event_1].to_json) }
    it { expect(described_class.by_project(-1)).to be_empty }
  end

  describe '.timerange' do
    let_it_be(:events) do
      create(:product_analytics_event, collector_tstamp: Time.zone.now - 1.day)
      create(:product_analytics_event, collector_tstamp: Time.zone.now - 5.days)
      create(:product_analytics_event, collector_tstamp: Time.zone.now - 15.days)
      create(:product_analytics_event, collector_tstamp: Time.zone.now - 1.month)
    end

    it { expect(described_class.timerange(7.days).size).to eq(2) }
    it { expect(described_class.timerange(60.days).size).to eq(4) }
  end
end
