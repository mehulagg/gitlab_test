# frozen_string_literal: true

require 'spec_helper'

describe Geo::ReplicableRepositorySyncWorker, :geo do
  describe '#perform' do
    it 'runs ReplicableRepositorySyncService' do
      registry_class_name = 'Geo::DesignRegistry'
      registry_id = 1234
      service = spy(:service)

      expect(Geo::ReplicableRepositorySyncService).to receive(:new).with(registry_class_name, registry_id).and_return(service)

      described_class.new.perform(registry_class_name, registry_id)

      expect(service).to have_received(:execute)
    end
  end
end
