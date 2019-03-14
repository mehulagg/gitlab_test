require 'spec_helper'

describe Gitlab::Ci::Config::Entry::Services do
  let(:entry) { described_class.new(config) }

  before do
    entry.compose!
  end

  context 'when configuration is valid' do
    let(:config) { ['postgresql:9.5', { name: 'postgresql:9.1', alias: 'postgres_old' }] }

    describe '#valid?' do
      it 'is valid' do
        expect(entry).to be_valid
      end
    end

    describe '#value' do
      it 'returns valid array' do
        expect(entry.value).to eq([{ name: 'postgresql:9.5' }, { name: 'postgresql:9.1', alias: 'postgres_old' }])
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

  context 'when configuration has ports' do
    let(:ports) { [{ number: 80, protocol: 'http', name: 'foobar' }] }
    let(:config) { ['postgresql:9.5', { name: 'postgresql:9.1', alias: 'postgres_old', ports: ports }] }
    let(:entry) { described_class.new(config, { with_image_ports: image_ports }) }
    let(:image_ports) { false }

    context 'when with_image_ports metadata is not enabled' do
      describe '#valid?' do
        it 'is not valid' do
          expect(entry).not_to be_valid
          expect(entry.errors).to include("service config contains disallowed keys: ports")
        end
      end
    end

    context 'when with_image_ports metadata is enabled' do
      let(:image_ports) { true }

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

      describe 'services alias' do
        context 'when they are not unique' do
          let(:config) do
            ['postgresql:9.5',
             { name: 'postgresql:9.1', alias: 'postgres_old', ports: ports },
             { name: 'ruby', alias: 'postgres_old' }]
          end

          describe '#valid?' do
            it 'is invalid' do
              expect(entry).not_to be_valid
              expect(entry.errors).to include("services config alias must be unique")
            end
          end
        end

        context 'when they are unique' do
          let(:config) do
            ['postgresql:9.5',
             { name: 'postgresql:9.1', alias: 'postgres_old', ports: ports },
             { name: 'ruby', alias: 'ruby' }]
          end

          describe '#valid?' do
            it 'is valid' do
              expect(entry).to be_valid
            end
          end
        end

        context 'when there are not any ports' do
          let(:config) do
            ['postgresql:9.5',
             { name: 'postgresql:9.1', alias: 'postgres_old' },
             { name: 'ruby', alias: 'postgres_old' }]
          end

          it 'alias can be duplicated' do
            expect(entry).to be_valid
          end
        end
      end
    end
  end
end
