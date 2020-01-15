# frozen_string_literal: true

require 'spec_helper'
require 'lib/gitlab/cycle_analytics/shared_event_spec'

describe Gitlab::ValueStreamAnalytics::IssueEventFetcher do
  let(:stage_name) { :issue }

  it_behaves_like 'default query config'
end
