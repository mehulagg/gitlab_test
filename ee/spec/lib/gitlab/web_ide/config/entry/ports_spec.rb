# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::WebIde::Config::Entry::Ports do
  let(:entry) { described_class.new(config) }

  before do
    entry.compose!
  end

  context 'when configuration is valid' do
    let(:config) { [{ external_port: 80, internal_port: 80, insecure: false, name: 'foobar' }] }

    describe '#valid?' do
      it 'is valid' do
        expect(entry).to be_valid
      end
    end

    describe '#value' do
      it 'returns valid array' do
        expect(entry.value).to eq(config)
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

    context 'when any of the ports' do
      before do
        expect(entry).not_to be_valid
        expect(entry.errors.count).to eq 1
      end

      context 'have the same name' do
        let(:config) do
          [{ external_port: 80, internal_port: 80, insecure: false, name: 'foobar' },
           { external_port: 81, internal_port: 81, insecure: false, name: 'foobar' }]
        end

        describe '#valid?' do
          it 'is invalid' do
            expect(entry.errors.first).to match "each port name must be different"
          end
        end
      end

      context 'have the same external port' do
        let(:config) do
          [{ external_port: 80, internal_port: 80, insecure: false, name: 'foobar' },
           { external_port: 80, internal_port: 81, insecure: false, name: 'foobar1' }]
        end

        describe '#valid?' do
          it 'is invalid' do
            expect(entry.errors.first).to match "each external port can only be referenced once in the block"
          end
        end
      end
    end
  end
end

