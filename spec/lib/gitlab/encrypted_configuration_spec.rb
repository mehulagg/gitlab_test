# frozen_string_literal: true

require "spec_helper"

describe Gitlab::EncryptedConfiguration do
  subject(:configuration) { described_class.new }

  describe '#initialize' do
    it 'accepts all args as optional fields' do
      expect { configuration }.not_to raise_exception

      expect(configuration.key).to be_nil
      expect(configuration.read_env_key).to be_nil
      expect(configuration.read_key_file).to be_nil
    end
  end

  context 'when provided key and config file' do
    let!(:config_tmp_dir) { Dir.mktmpdir('config-') }
    let(:credentials_config_path) { File.join(config_tmp_dir, 'credentials.yml.enc') }
    let(:credentials_key_path) { File.join(config_tmp_dir, 'somekey.key') }

    before do
      File.write(credentials_key_path, ActiveSupport::EncryptedConfiguration.generate_key)
    end

    after do
      FileUtils.rm_f(config_tmp_dir)
    end

    describe '#read' do
      it 'reads yaml configuration' do
        config = described_class.new(config_path: credentials_config_path, key_path: credentials_key_path)

        config.write({ foo: { bar: true } }.to_yaml)
        expect(config.foo[:bar]).to be true
      end
    end

    describe '#change' do
      it 'changes yaml configuration' do
        config = described_class.new(config_path: credentials_config_path, key_path: credentials_key_path)

        config.write({ foo: { bar: true } }.to_yaml)
        config.change do |unencrypted_file|
          contents = YAML.safe_load(unencrypted_file.read)
          unencrypted_file.write contents.merge(beef: "stew").to_yaml
        end
        expect(config.foo[:bar]).to be true
        expect(config.beef).to eq('stew')
      end
    end
  end
end
