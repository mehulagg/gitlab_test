# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::WebIde::Config::Entry::Port do
  let(:entry) { described_class.new(config) }

  before do
    entry.compose!
  end

  context 'when configuration is a string' do
    let(:config) { 80 }

    describe '#valid?' do
      it 'is valid' do
        expect(entry).to be_valid
      end
    end

    describe '#value' do
      it 'returns valid hash' do
        expect(entry.value).to eq(external_port: 80, internal_port: 80)
      end
    end

    describe '#external_port' do
      it "returns service's image external_port" do
        expect(entry.external_port).to eq 80
      end
    end

    describe '#internal_port' do
      it "returns service's internal_port" do
        expect(entry.internal_port).to eq 80
      end
    end

    describe '#insecure' do
      it "returns service's insecure" do
        expect(entry.insecure).to be false
      end
    end

    describe '#name' do
      it "returns service's name" do
        expect(entry.name).to be_nil
      end
    end
  end

  context 'when configuration is an array' do
    let(:config) { [80, 81] }

    describe '#valid?' do
      it 'is valid' do
        expect(entry).to be_valid
      end
    end

    describe '#value' do
      it 'returns valid hash' do
        expect(entry.value).to eq(external_port: 80, internal_port: 81)
      end
    end

    describe '#external_port' do
      it "returns service's image external_port" do
        expect(entry.external_port).to eq 80
      end
    end

    describe '#internal_port' do
      it "returns service's internal_port" do
        expect(entry.internal_port).to eq 81
      end
    end

    describe '#insecure' do
      it "returns service's insecure" do
        expect(entry.insecure).to be false
      end
    end

    describe '#name' do
      it "returns service's name" do
        expect(entry.name).to be_nil
      end
    end
  end

  context 'when configuration is a hash' do
    context 'with the complete hash' do
      let(:config) do
        { external_port: 80,
          internal_port: 81,
          insecure: true,
          name:  'foobar' }
      end

      describe '#valid?' do
        it 'is valid' do
          expect(entry).to be_valid
        end
      end

      describe '#value' do
        it 'returns valid hash' do
          expect(entry.value).to eq config
        end
      end

      describe '#external_port' do
        it "returns service's image external_port" do
          expect(entry.external_port).to eq 80
        end
      end

      describe '#internal_port' do
        it "returns service's internal_port" do
          expect(entry.internal_port).to eq 81
        end
      end

      describe '#insecure' do
        it "returns service's insecure" do
          expect(entry.insecure).to eq true
        end
      end

      describe '#name' do
        it "returns service's name" do
          expect(entry.name).to eq 'foobar'
        end
      end
    end

    context 'with only the external_port' do
      let(:config) { { external_port: 80 } }

      describe '#valid?' do
        it 'is valid' do
          expect(entry).to be_valid
        end
      end

      describe '#value' do
        it 'returns valid hash' do
          expect(entry.value).to eq(external_port: 80, internal_port: 80)
        end
      end

      describe '#external_port' do
        it "returns service's image external_port" do
          expect(entry.external_port).to eq 80
        end
      end

      describe '#internal_port' do
        it "returns service's internal_port" do
          expect(entry.internal_port).to eq 80
        end
      end

      describe '#insecure' do
        it "returns service's insecure" do
          expect(entry.insecure).to eq false
        end
      end

      describe '#name' do
        it "returns service's name" do
          expect(entry.name).to be_nil
        end
      end
    end

    context 'without the external_port' do
      let(:config) { { internal_port: 80 } }

      describe '#valid?' do
        it 'is valid' do
          expect(entry).not_to be_valid
        end
      end
    end
  end

  context 'when configuration is invalid' do
    let(:config) { '80' }

    describe '#valid?' do
      it 'is valid' do
        expect(entry).not_to be_valid
      end
    end
  end
end
