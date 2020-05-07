# frozen_string_literal: true

RSpec.shared_examples 'logs trigger info', include_shared: true do |trigger_type|
  it 'logs `trigger_type`' do
    expect(Gitlab::Geo::Logger).to receive(:info)
      .with(hash_including(trigger_type: trigger_type))
      .at_least(:once)
      .and_call_original

    perform
  end
end
