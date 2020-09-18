# frozen_string_literal: true

require "spec_helper"

RSpec.describe Gitlab::EncryptedConfiguration do
  subject(:configuration) { described_class.new }

  describe '#initialize' do
    it 'accepts all args as optional fields' do
      expect { configuration }.not_to raise_exception

      expect(configuration.key).to be_nil
      expect(configuration.previous_keys).to be_empty
    end
  end

  context 'when provided key and config file' do
    let!(:config_tmp_dir) { Dir.mktmpdir('config-') }
    let(:credentials_config_path) { File.join(config_tmp_dir, 'credentials.yml.enc') }
    let(:credentials_key) { ActiveSupport::EncryptedConfiguration.generate_key }

    after do
      FileUtils.rm_f(config_tmp_dir)
    end

    describe '#write' do
      it 'encrypts the file using the provided key' do
        encryptor = ActiveSupport::MessageEncryptor.new([credentials_key].pack('H*'), cipher: 'aes-128-gcm')
        config = described_class.new(content_path: credentials_config_path, key: credentials_key)

        config.write('sample-content')
        expect(encryptor.decrypt_and_verify(File.read(credentials_config_path))).to eq('sample-content')
      end
    end

    describe '#read' do
      it 'reads yaml configuration' do
        config = described_class.new(content_path: credentials_config_path, key: credentials_key)

        config.write({ foo: { bar: true } }.to_yaml)
        expect(config[:foo][:bar]).to be true
      end

      it 'allows referencing top level keys via dot syntax' do
        config = described_class.new(content_path: credentials_config_path, key: credentials_key)

        config.write({ foo: { bar: true } }.to_yaml)
        expect(config.foo[:bar]).to be true
      end
    end

    describe '#change' do
      it 'changes yaml configuration' do
        config = described_class.new(content_path: credentials_config_path, key: credentials_key)

        config.write({ foo: { bar: true } }.to_yaml)
        config.change do |unencrypted_file|
          contents = YAML.safe_load(unencrypted_file.read, [Symbol])
          unencrypted_file.write contents.merge(beef: "stew").to_yaml
        end
        expect(config.foo[:bar]).to be true
        expect(config.beef).to eq('stew')
      end
    end

    context 'when provided previous_keys for rotation' do
      let!(:config_tmp_dir) { Dir.mktmpdir('config-') }
      let(:credentials_keys) { Array.new(2) { ActiveSupport::EncryptedConfiguration.generate_key } }

      after do
        FileUtils.rm_f(config_tmp_dir)
      end

      def credentials_config_path(key)
        File.join(config_tmp_dir, "credentials-#{key}.yml.enc")
      end

      def encryptor(key)
        ActiveSupport::MessageEncryptor.new([key].pack('H*'), cipher: 'aes-128-gcm')
      end

      describe '#write' do
        it 'rotates the key when provided a new key' do
          config1 = described_class.new(content_path: credentials_config_path(1), key: credentials_keys[0])
          config1.write('sample-content1')

          config2 = described_class.new(content_path: credentials_config_path(2), key: credentials_keys[1], previous_keys: credentials_keys.slice(0, 1))
          config2.write('sample-content2')

          initial_key_encryptor = encryptor(credentials_keys[0]) # can read with the initial key
          new_key_encryptor = encryptor(credentials_keys[1]) # can read with the new key
          both_key_encryptor = encryptor(credentials_keys[1]) # can read with either key
          both_key_encryptor.rotate([credentials_keys[0]].pack("H*"))

          expect(initial_key_encryptor.decrypt_and_verify(File.read(credentials_config_path(1)))).to eq('sample-content1')
          expect(both_key_encryptor.decrypt_and_verify(File.read(credentials_config_path(1)))).to eq('sample-content1')
          expect(new_key_encryptor.decrypt_and_verify(File.read(credentials_config_path(2)))).to eq('sample-content2')
          expect(both_key_encryptor.decrypt_and_verify(File.read(credentials_config_path(2)))).to eq('sample-content2')
          expect {initial_key_encryptor.decrypt_and_verify(File.read(credentials_config_path(2))) }.to raise_error(ActiveSupport::MessageEncryptor::InvalidMessage)
        end
      end
    end
  end
end
