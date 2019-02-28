# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::WebIde::Config::Entry::Services do
  let(:entry) { described_class.new(config) }

  before do
    entry.compose!
  end

  context 'when configuration is valid' do
    let(:ports) { [{ external_port: 80, internal_port: 80, insecure: false, name: 'foobar' }] }
    let(:config) { ['postgresql:9.5', { name: 'postgresql:9.1', alias: 'postgres_old', ports: ports }] }

    describe '#valid?' do
      it 'is valid' do
        expect(entry).to be_valid
      end
    end

    describe '#value' do
      it 'returns valid array' do
        expect(entry.value).to eq([{ name: 'postgresql:9.5' }, { name: 'postgresql:9.1', alias: 'postgres_old', ports: ports }])
      end
    end
  end

  context 'when configuration is invalid' do
    let(:config) { 'postgresql:9.5' }

    describe '#valid?' do
      it 'is invalid' do
        expect(entry).not_to be_valid
      end
    end
  end
end
