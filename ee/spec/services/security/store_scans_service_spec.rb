# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::StoreScansService do
  let_it_be(:pipeline) { create(:ci_pipeline) }

  describe '.execute' do
    let(:mock_service_object) { instance_double(described_class, execute: true) }

    subject(:execute) { described_class.execute(pipeline) }

    before do
      allow(described_class).to receive(:new).with(pipeline).and_return(mock_service_object)
    end

    it 'delegates the call to an instance of `Security::StoreScansService`' do
      execute

      expect(described_class).to have_received(:new).with(pipeline)
      expect(mock_service_object).to have_received(:execute)
    end
  end
end
