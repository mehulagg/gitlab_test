# frozen_string_literal: true

require 'spec_helper'

describe Servers::DetectHighDiskUsageService do
  subject { described_class.new }

  describe '#execute' do
    context 'when no gitaly servers are configured' do
      let(:servers) { [] }

      it 'returns without iterating over servers' do
        allow(::Gitaly::Server).to receive(:all).and_return(servers)
        expect(subject).to receive(:servers).twice.and_return(servers)
        expect(subject.execute()).to be_nil
      end
    end

    context 'when only one gitaly server is configured' do
      let(:servers) { [{}] }

      it 'returns without iterating over servers' do
        expect(subject).to receive(:servers).exactly(3).times.and_return(servers)
        expect(subject.execute()).to be_nil
      end
    end

    context 'when more than one gitaly server is configured' do
      let(:server_a) { double('server') }
      let(:server_b) { double('server') }
      let(:servers) { [server_a, server_b] }

      it 'iterates over servers and returns those with usage exceeding 65 percent' do
        allow(::Gitaly::Server).to receive(:all).and_return(servers)
        expect(subject).to receive(:disk_usage_percentage).and_return(42)
        expect(subject).to receive(:disk_usage_percentage).and_return(66)
        expect(subject.execute()).to eq([server_b])
      end
    end
  end

  describe '#disk_usage_percentage' do
    let(:disk_used) { 42 }
    let(:disk_available) { 100 }
    let(:server) {
      server = double('server')
      allow(server).to receive(:address).and_return('address')
      allow(server).to receive(:disk_used).and_return(disk_used)
      allow(server).to receive(:disk_available).and_return(disk_available)
      server
    }

    it 'returns disk usage percentage for a given server' do
      expect(subject.send(:disk_usage_percentage, server)).to eq(disk_used)
    end

    context 'when disk available is 0' do
      let(:disk_available) { 0 }

      it 'returns 0 for a given server' do
        expect(subject.send(:disk_usage_percentage, server)).to eq(0)
      end
    end
  end
end
