# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::WebIde::Config::Entry::Image do
  let(:entry) { described_class.new(config) }

  context 'when configuration is a string' do
    let(:config) { 'ruby:2.2' }

    describe '#value' do
      it 'returns image hash' do
        expect(entry.value).to eq({ name: 'ruby:2.2' })
      end
    end

    describe '#errors' do
      it 'does not append errors' do
        expect(entry.errors).to be_empty
      end
    end

    describe '#valid?' do
      it 'is valid' do
        expect(entry).to be_valid
      end
    end

    describe '#image' do
      it "returns image's name" do
        expect(entry.name).to eq 'ruby:2.2'
      end
    end

    describe '#entrypoint' do
      it "returns image's entrypoint" do
        expect(entry.entrypoint).to be_nil
      end
    end

    describe '#ports' do
      it "returns image's ports" do
        expect(entry.ports).to be_nil
      end
    end
  end

  context 'when configuration is a hash' do
    let(:ports) { [{ external_port: 80, internal_port: 80, insecure: false, name: 'foobar' }] }
    let(:config) { { name: 'ruby:2.2', entrypoint: %w(/bin/sh run), ports: ports } }

    describe '#value' do
      it 'returns image hash' do
        expect(entry.value).to eq(config)
      end
    end

    describe '#errors' do
      it 'does not append errors' do
        expect(entry.errors).to be_empty
      end
    end

    describe '#valid?' do
      it 'is valid' do
        expect(entry).to be_valid
      end
    end

    describe '#image' do
      it "returns image's name" do
        expect(entry.name).to eq 'ruby:2.2'
      end
    end

    describe '#entrypoint' do
      it "returns image's entrypoint" do
        expect(entry.entrypoint).to eq %w(/bin/sh run)
      end
    end

    describe '#ports' do
      it "returns image's ports" do
        expect(entry.ports).to eq ports
      end
    end
  end

  context 'when entry value is not correct' do
    let(:config) { ['ruby:2.2'] }

    describe '#errors' do
      it 'saves errors' do
        expect(entry.errors)
          .to include 'image config should be a hash or a string'
      end
    end

    describe '#valid?' do
      it 'is not valid' do
        expect(entry).not_to be_valid
      end
    end
  end

  context 'when unexpected key is specified' do
    let(:config) { { name: 'ruby:2.2', non_existing: 'test' } }

    describe '#errors' do
      it 'saves errors' do
        expect(entry.errors)
            .to include 'image config contains unknown keys: non_existing'
      end
    end

    describe '#valid?' do
      it 'is not valid' do
        expect(entry).not_to be_valid
      end
    end
  end
end
