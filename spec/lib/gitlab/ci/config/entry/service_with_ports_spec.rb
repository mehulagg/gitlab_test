require 'spec_helper'

describe Gitlab::Ci::Config::Entry::ServiceWithPorts do
  let(:entry) { described_class.new(config) }

  before do
    entry.compose!
  end

  include_examples 'CI::Config::Entry::Service validations'

  context 'when configuration is a string' do
    let(:config) { 'postgresql:9.5' }

    describe '#ports' do
      it "returns service's ports" do
        expect(entry.ports).to be_nil
      end
    end
  end

  context 'when configuration is a hash' do
    let(:ports) { [{ number: 80, insecure: false, name: 'foobar' }] }
    let(:config) do
      { name: 'postgresql:9.5', alias: 'db', command: %w(cmd run), entrypoint: %w(/bin/sh run), ports: ports }
    end

    describe '#ports' do
      it "returns service's ports" do
        expect(entry.ports).to eq ports
      end
    end
  end

  context 'when service has ports' do
    let(:ports) { [{ number: 80, insecure: false, name: 'foobar' }] }
    let(:config) do
      { name: 'postgresql:9.5', command: %w(cmd run), entrypoint: %w(/bin/sh run), ports: ports }
    end

    it 'alias field is mandatory' do
      expect(entry).not_to be_valid
      expect(entry.errors).to include("service with ports alias can't be blank")
    end
  end

  context 'when service does not have ports' do
    let(:config) do
      { name: 'postgresql:9.5', alias: 'db', command: %w(cmd run), entrypoint: %w(/bin/sh run) }
    end

    it 'alias field is optional' do
      expect(entry).to be_valid
    end
  end
end
