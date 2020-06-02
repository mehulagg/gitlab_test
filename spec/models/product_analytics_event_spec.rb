# frozen_string_literal: true
require 'spec_helper'

RSpec.describe ProductAnalyticsEvent, type: :model do
  it { expect(described_class).to respond_to(:order_by_time) }
  it { expect(described_class).to respond_to(:count_by_graph) }
  it { expect(described_class).to respond_to(:count_by_day_and_graph) }

  describe '.by_project' do
    let_it_be(:event_1) { create(:product_analytics_event, app_id: '7') }
    let_it_be(:event_2) { create(:product_analytics_event, app_id: '9') }

    it { expect(described_class.by_project(7).to_json).to eq([event_1].to_json) }
    it { expect(described_class.by_project(-1)).to be_empty }
  end

  describe '.timerange' do
    let_it_be(:event_1) { create(:product_analytics_event, collector_tstamp: Time.zone.now - 1.month) }
    let_it_be(:event_2) { create(:product_analytics_event, collector_tstamp: Time.zone.now + 1.month) }
    let_it_be(:event_3) { create(:product_analytics_event, collector_tstamp: Time.zone.now - 1.day) }
    let_it_be(:event_4) { create(:product_analytics_event, collector_tstamp: Time.zone.now + 1.day) }

    it { expect(described_class.timerange(5.days).to_json).to eq([event_3, event_4].to_json) }
    it { expect(described_class.timerange(60.days).to_json).to eq([event_1, event_2, event_3, event_4].to_json) }
  end
end
