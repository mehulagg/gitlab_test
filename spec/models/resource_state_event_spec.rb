# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ResourceStateEvent, type: :model do
  using RSpec::Parameterized::TableSyntax

  subject { build(:resource_state_event, issue: issue) }

  let(:issue) { create(:issue) }
  let(:merge_request) { create(:merge_request) }

  it_behaves_like 'a resource event'
  it_behaves_like 'a resource event for issues'
  it_behaves_like 'a resource event for merge requests'

  describe '#state' do
    where(:close_after_error_tracking_resolve, :close_auto_resolve_prometheus_alert, :expected_result) do
      true | false | 'closed'
      true | true | 'closed'
      false | true | 'closed'
      false | false | 'opened'
    end

    with_them do
      it do
        event = build(:resource_state_event,
                      close_after_error_tracking_resolve: close_after_error_tracking_resolve,
                      close_auto_resolve_prometheus_alert: close_auto_resolve_prometheus_alert)

        expect(event.state).to eq(expected_result)
      end
    end
  end
end
