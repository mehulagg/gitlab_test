# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:each, :snowplow) do
    stub_application_setting(snowplow_enabled: true)

    allow(SnowplowTracker::AsyncEmitter)
      .to receive(:new)
      .and_return(SnowplowTracker::Emitter.new('localhost', buffer_size: 1))
  end
end
