require 'spec_helper'

describe Gitlab::Ci::Build::Port do
  subject { described_class.new(port) }

  context 'when port is defined as an integer' do
    let(:port) { 80 }

    it 'populates the object' do
      expect(subject.external_port).to eq 80
      expect(subject.internal_port).to eq 80
      expect(subject.insecure).to eq false
      expect(subject.name).to eq described_class::DEFAULT_PORT_NAME
    end
  end

  context 'when port is defined as an array' do
    let(:port) { [80, 81] }

    it 'populates the object' do
      expect(subject.external_port).to eq 80
      expect(subject.internal_port).to eq 81
      expect(subject.insecure).to eq false
      expect(subject.name).to eq described_class::DEFAULT_PORT_NAME
    end
  end

  context 'when port is defined as hash' do
    let(:port) { { external_port: 80, internal_port: 81, insecure: true, name: 'port_name' } }

    it 'populates the object' do
      expect(subject.external_port).to eq 80
      expect(subject.internal_port).to eq 81
      expect(subject.insecure).to eq true
      expect(subject.name).to eq 'port_name'
    end
  end
end
