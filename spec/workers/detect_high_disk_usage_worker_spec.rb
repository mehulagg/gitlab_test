# frozen_string_literal: true

require 'spec_helper'

describe DetectHighDiskUsageWorker do
  subject { described_class.new }

  describe '#perform' do
    it 'calls the DetectServersWithHighDiskUsage service' do
      service = double
      allow(::Servers::DetectHighDiskUsageService).to receive(:new).and_return(service)
      expect(service).to receive(:execute)

      subject.perform()
    end

    context 'when gitaly service is not available' do
      it 'raises an exception when the remote procedure call times out' do
        expect do
          subject.perform()
        end.to raise_error(StandardError)
      end
    end
  end
end
