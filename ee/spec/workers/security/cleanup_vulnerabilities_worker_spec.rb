# frozen_string_literal: true

require 'spec_helper'

describe Security::CleanupVulnerabilitiesWorker do
  let(:worker) { described_class.new }

  it 'triggers cleanup service' do
    expect_any_instance_of(::Security::CleanupVulnerabilities).to receive(:execute)

    worker.perform
  end
end